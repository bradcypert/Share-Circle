defmodule ShareCircle.Repo.Migrations.CreateCalendarTables do
  use Ecto.Migration

  def change do
    create table(:calendar_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :created_by_user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :title, :text, null: false
      add :description, :text
      add :location, :text
      add :starts_at, :utc_datetime_usec, null: false
      add :ends_at, :utc_datetime_usec
      add :all_day, :boolean, null: false, default: false
      add :timezone, :text, null: false
      add :cover_media_id, references(:media_items, type: :binary_id, on_delete: :nilify_all)
      add :deleted_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create index(:calendar_events, [:family_id, :starts_at],
             where: "deleted_at IS NULL",
             name: :calendar_events_family_time)

    create table(:rsvps, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:calendar_events, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :status, :text, null: false
      add :guest_count, :integer, null: false, default: 0
      add :note, :text
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:rsvps, [:event_id, :user_id])
    create index(:rsvps, [:event_id])
  end
end
