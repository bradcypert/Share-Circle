defmodule ShareCircleWeb.LiveHelpers do
  @moduledoc false

  alias ShareCircle.Media

  @doc "Builds a map of media_item_id => presigned URL for all post_media in the given posts."
  def build_media_urls(scope, posts) do
    posts
    |> Enum.flat_map(fn post -> post.post_media || [] end)
    |> Enum.reduce(%{}, fn pm, acc ->
      item = pm.media_item
      variant_kind = if item.kind == "video", do: "thumb_256", else: "thumb_1024"

      case Media.get_variant_url(scope, item.id, variant_kind) do
        {:ok, url} -> Map.put(acc, item.id, url)
        {:error, _} -> acc
      end
    end)
  end
end
