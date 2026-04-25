defmodule ShareCircleWeb.ProfileLive do
  use ShareCircleWeb, :live_view

  alias ShareCircle.Families
  alias ShareCircle.Posts
  alias ShareCircleWeb.LiveHelpers

  @impl true
  def mount(%{"family_id" => family_id, "user_id" => profile_user_id}, _session, socket) do
    user = socket.assigns.current_scope.user

    case Families.get_membership_for_user(family_id, user.id) do
      nil ->
        {:ok, push_navigate(socket, to: ~p"/families")}

      %{family: family} = membership ->
        scope = %{socket.assigns.current_scope | family: family, membership: membership}

        case Families.get_membership_for_user(family_id, profile_user_id) do
          nil ->
            {:ok, push_navigate(socket, to: ~p"/families/#{family_id}/members")}

          profile_membership ->
            if connected?(socket), do: Process.send_after(self(), :refresh_media_urls, 240_000)

            {posts, pagination} = Posts.list_posts_by_author(scope, profile_user_id)
            media_urls = build_media_urls(scope, posts)

            {:ok,
             socket
             |> assign(:current_scope, scope)
             |> assign(:family_id, family_id)
             |> assign(:profile_membership, profile_membership)
             |> assign(:profile_user, profile_membership.user)
             |> assign(:posts, posts)
             |> assign(:pagination, pagination)
             |> assign(:media_urls, media_urls)}
        end
    end
  end

  @impl true
  def handle_event("load_more", _params, socket) do
    scope = socket.assigns.current_scope
    cursor = socket.assigns.pagination.cursor

    {new_posts, pagination} =
      Posts.list_posts_by_author(scope, socket.assigns.profile_user.id, cursor: cursor)

    {:noreply,
     socket
     |> update(:posts, &(&1 ++ new_posts))
     |> assign(:pagination, pagination)
     |> update(:media_urls, &Map.merge(&1, build_media_urls(scope, new_posts)))}
  end

  def handle_info(:refresh_media_urls, socket) do
    Process.send_after(self(), :refresh_media_urls, 240_000)
    scope = socket.assigns.current_scope
    {:noreply, assign(socket, :media_urls, build_media_urls(scope, socket.assigns.posts))}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp build_media_urls(scope, posts), do: LiveHelpers.build_media_urls(scope, posts)
end
