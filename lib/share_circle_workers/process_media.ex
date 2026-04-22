defmodule ShareCircle.Workers.ProcessMedia do
  @moduledoc "Routes media items to the appropriate processing worker."

  use Oban.Worker, queue: :media, max_attempts: 3

  alias ShareCircle.Media.MediaItem
  alias ShareCircle.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"media_item_id" => media_item_id}}) do
    item = Repo.get!(MediaItem, media_item_id)

    case item.kind do
      "image" -> ShareCircle.Workers.ProcessImage.process(item)
      "video" -> ShareCircle.Workers.ProcessVideo.process(item)
      _ -> mark_ready(item)
    end
  end

  defp mark_ready(item) do
    item
    |> MediaItem.update_processing_changeset("ready")
    |> Repo.update!()

    :ok
  end
end
