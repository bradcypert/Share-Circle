defmodule ShareCircleWeb.Api.V1.ReactionController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Posts

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  # PUT /api/v1/posts/:post_id/reactions/:emoji
  # PUT /api/v1/comments/:comment_id/reactions/:emoji
  def upsert(conn, %{"post_id" => post_id, "emoji" => emoji}) do
    do_react(conn, "post", post_id, emoji)
  end

  def upsert(conn, %{"comment_id" => comment_id, "emoji" => emoji}) do
    do_react(conn, "comment", comment_id, emoji)
  end

  # DELETE /api/v1/posts/:post_id/reactions/:emoji
  # DELETE /api/v1/comments/:comment_id/reactions/:emoji
  def delete(conn, %{"post_id" => post_id, "emoji" => emoji}) do
    do_unreact(conn, "post", post_id, emoji)
  end

  def delete(conn, %{"comment_id" => comment_id, "emoji" => emoji}) do
    do_unreact(conn, "comment", comment_id, emoji)
  end

  defp do_react(conn, subject_type, subject_id, emoji) do
    with :ok <- Posts.react(conn.assigns.current_scope, subject_type, subject_id, emoji) do
      send_resp(conn, :no_content, "")
    end
  end

  defp do_unreact(conn, subject_type, subject_id, emoji) do
    with :ok <- Posts.unreact(conn.assigns.current_scope, subject_type, subject_id, emoji) do
      send_resp(conn, :no_content, "")
    end
  end
end
