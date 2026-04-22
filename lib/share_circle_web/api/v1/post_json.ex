defmodule ShareCircleWeb.Api.V1.PostJSON do
  alias ShareCircle.Posts.Post

  def render(post), do: data(post)

  defp data(%Post{} = post) do
    %{
      id: post.id,
      kind: post.kind,
      body: post.body,
      metadata: post.metadata,
      author: author(post),
      family_id: post.family_id,
      edited_at: post.edited_at,
      inserted_at: post.inserted_at,
      updated_at: post.updated_at
    }
  end

  defp author(%Post{author: %{id: id, display_name: name}}), do: %{id: id, display_name: name}
  defp author(_), do: nil
end
