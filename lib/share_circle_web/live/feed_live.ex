defmodule ShareCircleWeb.FeedLive do
  use ShareCircleWeb, :live_view

  alias ShareCircle.Posts
  alias ShareCircle.PubSub

  @impl true
  def mount(%{"family_id" => family_id}, _session, socket) do
    user = socket.assigns.current_scope.user

    case ShareCircle.Families.get_membership_for_user(family_id, user.id) do
      nil ->
        {:ok, push_navigate(socket, to: ~p"/families")}

      %{family: family} = membership ->
        scope = %{socket.assigns.current_scope | family: family, membership: membership}

        if connected?(socket) do
          PubSub.subscribe(PubSub.family_topic(family.id))
        end

        {posts, pagination} = Posts.list_posts(scope)

        {:ok,
         socket
         |> assign(:current_scope, scope)
         |> assign(:posts, posts)
         |> assign(:pagination, pagination)
         |> assign(:post_body, "")}
    end
  end

  @impl true
  def handle_event("create_post", %{"body" => body}, socket) do
    case Posts.create_post(socket.assigns.current_scope, %{"kind" => "text", "body" => body}) do
      {:ok, _post} -> {:noreply, assign(socket, :post_body, "")}
      {:error, _} -> {:noreply, socket}
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
