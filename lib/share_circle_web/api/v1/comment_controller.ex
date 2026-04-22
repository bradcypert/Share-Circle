defmodule ShareCircleWeb.Api.V1.CommentController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Posts
  alias ShareCircleWeb.Api.V1.{CommentJSON, Response}

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  # GET /api/v1/posts/:post_id/comments
  def index(conn, %{"post_id" => post_id}) do
    with {:ok, comments} <- Posts.list_comments(conn.assigns.current_scope, post_id) do
      Response.render_data(conn, Enum.map(comments, &CommentJSON.render/1))
    end
  end

  # POST /api/v1/families/:family_id/posts/:post_id/comments
  def create(conn, %{"post_id" => post_id, "comment" => comment_params}) do
    with {:ok, comment} <-
           Posts.create_comment(conn.assigns.current_scope, post_id, comment_params) do
      Response.render_data(conn, CommentJSON.render(comment), :created)
    end
  end

  # PATCH /api/v1/comments/:id
  def update(conn, %{"id" => id, "comment" => comment_params}) do
    with {:ok, comment} <- Posts.update_comment(conn.assigns.current_scope, id, comment_params) do
      Response.render_data(conn, CommentJSON.render(comment))
    end
  end

  # DELETE /api/v1/comments/:id
  def delete(conn, %{"id" => id}) do
    with {:ok, _comment} <- Posts.delete_comment(conn.assigns.current_scope, id) do
      send_resp(conn, :no_content, "")
    end
  end
end
