defmodule ShareCircleWeb.EventsLive do
  use ShareCircleWeb, :live_view

  alias ShareCircle.Calendar
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

        events = Calendar.list_events(scope)

        {:ok,
         socket
         |> assign(:current_scope, scope)
         |> assign(:family_id, family_id)
         |> assign(:events, events)
         |> assign(:show_form, false)
         |> assign(:event_form, new_event_form())}
    end
  end

  @impl true
  def handle_event("toggle_form", _params, socket) do
    {:noreply, assign(socket, :show_form, !socket.assigns.show_form)}
  end

  def handle_event("create_event", %{"event" => attrs}, socket) do
    scope = socket.assigns.current_scope

    case Calendar.create_event(scope, attrs) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> assign(:show_form, false)
         |> assign(:event_form, new_event_form())}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("rsvp", %{"event_id" => event_id, "status" => status}, socket) do
    scope = socket.assigns.current_scope
    Calendar.upsert_rsvp(scope, event_id, %{"status" => status})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:event_created, %{event: event}}, socket) do
    {:noreply, update(socket, :events, &insert_sorted(&1, event))}
  end

  def handle_info({:event_updated, %{event: updated}}, socket) do
    {:noreply,
     update(socket, :events, fn events ->
       Enum.map(events, fn e -> if e.id == updated.id, do: updated, else: e end)
     end)}
  end

  def handle_info({:event_deleted, %{event_id: id}}, socket) do
    {:noreply, update(socket, :events, &Enum.reject(&1, fn e -> e.id == id end))}
  end

  def handle_info({:rsvp_updated, %{rsvp: rsvp}}, socket) do
    # Reload the affected event so RSVP counts update in place
    scope = socket.assigns.current_scope

    events =
      Enum.map(socket.assigns.events, fn e ->
        if e.id == rsvp.event_id do
          case Calendar.get_event(scope, e.id) do
            {:ok, refreshed} -> refreshed
            _ -> e
          end
        else
          e
        end
      end)

    {:noreply, assign(socket, :events, events)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp format_datetime(dt, _tz) do
    Elixir.Calendar.strftime(dt, "%b %-d, %Y %-I:%M %p")
  end

  defp rsvp_count(%{rsvps: rsvps}, status) when is_list(rsvps) do
    Enum.count(rsvps, &(&1.status == status))
  end

  defp rsvp_count(_, _), do: 0

  defp new_event_form do
    now = DateTime.utc_now()
    to_form(%{
      "title" => "",
      "description" => "",
      "location" => "",
      "starts_at" => DateTime.to_iso8601(now),
      "timezone" => "UTC",
      "all_day" => false
    }, as: "event")
  end

  defp insert_sorted(events, new_event) do
    [new_event | events]
    |> Enum.sort_by(& &1.starts_at, DateTime)
  end
end
