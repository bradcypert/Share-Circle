defmodule ShareCircleWeb.Api.V1.CommentJSON do
  alias ShareCircle.Posts.Comment

  def render(comment), do: data(comment)

  defp data(%Comment{} = comment) do
    %{
      id: comment.id,
      post_id: comment.post_id,
      body: comment.body,
      author: author(comment),
      parent_comment_id: comment.parent_comment_id,
      edited_at: comment.edited_at,
      inserted_at: comment.inserted_at,
      updated_at: comment.updated_at
    }
  end

  defp author(%Comment{author: %{id: id, display_name: name}}), do: %{id: id, display_name: name}
  defp author(_), do: nil
end
