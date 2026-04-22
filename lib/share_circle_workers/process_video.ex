defmodule ShareCircle.Workers.ProcessVideo do
  @moduledoc """
  Generates thumb_256 (frame at 1s) and video_720p (H.264 MP4) variants.
  Requires ffmpeg on PATH.
  """

  alias ShareCircle.Media.{MediaItem, MediaVariant}
  alias ShareCircle.Repo
  alias ShareCircle.Storage
  alias ShareCircle.Storage.Local

  def process(%MediaItem{} = item) do
    item
    |> MediaItem.update_processing_changeset("processing")
    |> Repo.update!()

    case do_process(item) do
      :ok ->
        item
        |> MediaItem.update_processing_changeset("ready")
        |> Repo.update!()

        :ok

      {:error, reason} ->
        item
        |> MediaItem.update_processing_changeset("failed", error: inspect(reason))
        |> Repo.update!()

        {:error, reason}
    end
  end

  defp do_process(item) do
    with {:ok, src_path} <- temp_copy(item) do
      try do
        results = [
          generate_thumb(item, src_path),
          generate_720p(item, src_path)
        ]

        errors = Enum.filter(results, &match?({:error, _}, &1))

        if errors == [] do
          :ok
        else
          {:error, hd(errors)}
        end
      after
        File.rm(src_path)
      end
    end
  end

  defp generate_thumb(item, src_path) do
    out_path = System.tmp_dir!() <> "/thumb_#{item.id}.jpg"
    variant_key = variant_key(item.storage_key, "thumb_256")

    args = [
      "-y", "-ss", "1",
      "-i", src_path,
      "-vframes", "1",
      "-vf", "scale=256:256:force_original_aspect_ratio=increase,crop=256:256",
      out_path
    ]

    case System.cmd("ffmpeg", args, stderr_to_stdout: true) do
      {_, 0} ->
        with {:ok, data} <- File.read(out_path),
             :ok <- write_variant(variant_key, data) do
          File.rm(out_path)

          Repo.insert!(
            MediaVariant.changeset(%{
              media_item_id: item.id,
              variant_kind: "thumb_256",
              storage_key: variant_key,
              mime_type: "image/jpeg",
              byte_size: byte_size(data),
              width: 256,
              height: 256
            }),
            on_conflict: {:replace, [:storage_key, :byte_size]},
            conflict_target: [:media_item_id, :variant_kind]
          )

          :ok
        end

      {output, code} ->
        {:error, "ffmpeg exited #{code}: #{output}"}
    end
  end

  defp generate_720p(item, src_path) do
    out_path = System.tmp_dir!() <> "/video_#{item.id}_720p.mp4"
    variant_key = variant_key(item.storage_key, "video_720p")

    args = [
      "-y",
      "-i", src_path,
      "-vf", "scale=-2:720",
      "-c:v", "libx264",
      "-preset", "fast",
      "-crf", "23",
      "-c:a", "aac",
      "-b:a", "128k",
      "-movflags", "+faststart",
      out_path
    ]

    case System.cmd("ffmpeg", args, stderr_to_stdout: true) do
      {_, 0} ->
        with {:ok, data} <- File.read(out_path),
             :ok <- write_variant(variant_key, data) do
          File.rm(out_path)

          Repo.insert!(
            MediaVariant.changeset(%{
              media_item_id: item.id,
              variant_kind: "video_720p",
              storage_key: variant_key,
              mime_type: "video/mp4",
              byte_size: byte_size(data)
            }),
            on_conflict: {:replace, [:storage_key, :byte_size]},
            conflict_target: [:media_item_id, :variant_kind]
          )

          :ok
        end

      {output, code} ->
        {:error, "ffmpeg exited #{code}: #{output}"}
    end
  end

  defp temp_copy(item) do
    case Storage.adapter() do
      Local ->
        with {:ok, data} <- Local.read(item.storage_key) do
          ext = Path.extname(item.storage_key)
          tmp = System.tmp_dir!() <> "/src_#{item.id}#{ext}"
          :ok = File.write(tmp, data)
          {:ok, tmp}
        end

      _ ->
        {:error, :unsupported_adapter_for_processing}
    end
  end

  defp write_variant(key, data) do
    case Storage.adapter() do
      Local -> Local.store(key, data)
      _ -> {:error, :unsupported_adapter_for_processing}
    end
  end

  defp variant_key(original_key, kind) do
    dir = Path.dirname(original_key)
    base = Path.basename(original_key, Path.extname(original_key))
    ext = if String.contains?(kind, "video"), do: ".mp4", else: ".jpg"
    "#{dir}/#{base}_#{kind}#{ext}"
  end
end
