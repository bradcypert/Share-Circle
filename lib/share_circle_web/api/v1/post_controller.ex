defmodule ShareCircleWeb.Api.V1.PostController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Posts
  alias ShareCircleWeb.Api.V1.{PostJSON, Response}

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  # GET /api/v1/families/:family_id/posts
  def index(conn, params) do
    scope = conn.assigns.current_scope
    opts = [limit: parse_limit(params["limit"]), cursor: params["cursor"]]
    {posts, pagination} = Posts.list_posts(scope, opts)

    Response.render_collection(conn, Enum.map(posts, &PostJSON.render/1), pagination)
  end

  # GET /api/v1/posts/:id
  def show(conn, %{"id" => id}) do
    with {:ok, post} <- Posts.get_post(conn.assigns.current_scope, id) do
      Response.render_data(conn, PostJSON.render(post))
    end
  end

  # POST /api/v1/families/:family_id/posts
  def create(conn, %{"post" => post_params}) do
    with {:ok, post} <- Posts.create_post(conn.assigns.current_scope, post_params) do
      Response.render_data(conn, PostJSON.render(post), :created)
    end
  end

  # PATCH /api/v1/posts/:id
  def update(conn, %{"id" => id, "post" => post_params}) do
    with {:ok, post} <- Posts.update_post(conn.assigns.current_scope, id, post_params) do
      Response.render_data(conn, PostJSON.render(post))
    end
  end

  # DELETE /api/v1/posts/:id
  def delete(conn, %{"id" => id}) do
    with {:ok, _post} <- Posts.delete_post(conn.assigns.current_scope, id) do
      send_resp(conn, :no_content, "")
    end
  end

  defp parse_limit(nil), do: 25
  defp parse_limit(v) when is_binary(v), do: min(String.to_integer(v), 100)
  defp parse_limit(v) when is_integer(v), do: min(v, 100)
end
