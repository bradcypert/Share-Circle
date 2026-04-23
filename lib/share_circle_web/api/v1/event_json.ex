defmodule ShareCircleWeb.Api.V1.EventJSON do
  alias ShareCircle.Calendar.CalendarEvent

  def render(%CalendarEvent{} = event, my_rsvp \\ nil) do
    %{
      id: event.id,
      family_id: event.family_id,
      title: event.title,
      description: event.description,
      location: event.location,
      starts_at: event.starts_at,
      ends_at: event.ends_at,
      all_day: event.all_day,
      timezone: event.timezone,
      created_by: creator(event),
      rsvp_counts: rsvp_counts(event),
      my_rsvp: my_rsvp && %{status: my_rsvp.status, guest_count: my_rsvp.guest_count},
      inserted_at: event.inserted_at,
      updated_at: event.updated_at
    }
  end

  defp creator(%CalendarEvent{created_by_user: %{id: id, display_name: name}}),
    do: %{id: id, display_name: name}

  defp creator(_), do: nil

  defp rsvp_counts(%CalendarEvent{rsvps: rsvps}) when is_list(rsvps) do
    Enum.frequencies_by(rsvps, & &1.status)
  end

  defp rsvp_counts(_), do: %{}
end
