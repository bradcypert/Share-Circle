defmodule ShareCircle.Calendar.CalendarEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias ShareCircle.Accounts.User
  alias ShareCircle.Calendar.RSVP
  alias ShareCircle.Families.Family
  alias ShareCircle.Media.MediaItem

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "calendar_events" do
    belongs_to :family, Family
    belongs_to :created_by_user, User
    belongs_to :cover_media, MediaItem, foreign_key: :cover_media_id
    has_many :rsvps, RSVP, foreign_key: :event_id

    field :title, :string
    field :description, :string
    field :location, :string
    field :starts_at, :utc_datetime_usec
    field :ends_at, :utc_datetime_usec
    field :all_day, :boolean, default: false
    field :timezone, :string
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [
      :family_id,
      :created_by_user_id,
      :title,
      :description,
      :location,
      :starts_at,
      :ends_at,
      :all_day,
      :timezone,
      :cover_media_id
    ])
    |> validate_required([:family_id, :created_by_user_id, :title, :starts_at, :timezone])
    |> validate_length(:title, min: 1, max: 500)
    |> validate_ends_after_starts()
  end

  def update_changeset(event, attrs) do
    event
    |> cast(attrs, [
      :title,
      :description,
      :location,
      :starts_at,
      :ends_at,
      :all_day,
      :timezone,
      :cover_media_id
    ])
    |> validate_required([:title, :starts_at, :timezone])
    |> validate_length(:title, min: 1, max: 500)
    |> validate_ends_after_starts()
  end

  defp validate_ends_after_starts(changeset) do
    starts = get_field(changeset, :starts_at)
    ends = get_field(changeset, :ends_at)

    if starts && ends && DateTime.compare(ends, starts) == :lt do
      add_error(changeset, :ends_at, "must be after starts_at")
    else
      changeset
    end
  end
end
