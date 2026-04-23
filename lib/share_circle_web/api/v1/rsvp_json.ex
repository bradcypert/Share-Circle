defmodule ShareCircleWeb.Api.V1.RsvpJSON do
  alias ShareCircle.Calendar.RSVP

  def render(%RSVP{} = rsvp) do
    %{
      id: rsvp.id,
      event_id: rsvp.event_id,
      user_id: rsvp.user_id,
      status: rsvp.status,
      guest_count: rsvp.guest_count,
      note: rsvp.note,
      inserted_at: rsvp.inserted_at,
      updated_at: rsvp.updated_at
    }
  end
end
