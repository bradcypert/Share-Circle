defmodule ShareCircle.Calendar.RSVP do
  use Ecto.Schema
  import Ecto.Changeset

  alias ShareCircle.Accounts.User
  alias ShareCircle.Calendar.CalendarEvent
  alias ShareCircle.Families.Family

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @valid_statuses ~w(going maybe not_going)

  schema "rsvps" do
    belongs_to :event, CalendarEvent
    belongs_to :user, User
    belongs_to :family, Family

    field :status, :string
    field :guest_count, :integer, default: 0
    field :note, :string

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(rsvp, attrs) do
    rsvp
    |> cast(attrs, [:event_id, :user_id, :family_id, :status, :guest_count, :note])
    |> validate_required([:event_id, :user_id, :family_id, :status])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_number(:guest_count, greater_than_or_equal_to: 0)
    |> unique_constraint([:event_id, :user_id])
  end
end
