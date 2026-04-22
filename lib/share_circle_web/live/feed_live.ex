defmodule ShareCircleWeb.FeedLive do
  use ShareCircleWeb, :live_view

  alias ShareCircle.Posts
  alias ShareCircle.PubSub

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      PubSub.subscribe(PubSub.family_topic(scope.family.id))
    end

    {posts, pagination} = Posts.list_posts(scope)

    {:ok,
     socket
     |> assign(:posts, posts)
     |> assign(:pagination, pagination)
     |> assign(:post_body, "")
     |> assign(:submitting, false)}
  end

  @impl true
  def handle_event("create_post", %{"body" => body}, socket) do
    scope = socket.assigns.current_scope

    case Posts.create_post(scope, %{"kind" => "text", "body" => body}) do
      {:ok, _post} ->
        {:noreply, assign(socket, :post_body, "")}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("update_body", %{"value" => value}, socket) do
    {:noreply, assign(socket, :post_body, value)}
  end

  @impl true
  def handle_info({:post_created, %{post: post}}, socket) do
    {:noreply, update(socket, :posts, &[post | &1])}
  end

  def handle_info({:post_deleted, %{post_id: id}}, socket) do
    {:noreply, update(socket, :posts, &Enum.reject(&1, fn p -> p.id == id end))}
  end

  def handle_info({:post_updated, %{post: updated}}, socket) do
    {:noreply,
     update(socket, :posts, fn posts ->
       Enum.map(posts, fn p -> if p.id == updated.id, do: updated, else: p end)
     end)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}
end
