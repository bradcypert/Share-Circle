defmodule ShareCircle.Repo.Migrations.CreateChatTables do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :kind, :string, null: false
      add :name, :string
      add :created_by_user_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :last_message_at, :utc_datetime_usec
      add :last_message_preview, :string
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:conversations, [:family_id, :last_message_at],
             where: "deleted_at IS NULL",
             name: :conversations_family_recent
           )

    # Exactly one family-wide conversation per family
    create unique_index(:conversations, [:family_id],
             where: "kind = 'family'",
             name: :conversations_family_kind_unique
           )

    create table(:conversation_members, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :conversation_id,
          references(:conversations, type: :binary_id, on_delete: :delete_all),
          null: false

      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :joined_at, :utc_datetime_usec, null: false
      # no FK: message may be deleted
      add :last_read_message_id, :binary_id
      add :muted_until, :utc_datetime_usec
      add :left_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:conversation_members, [:conversation_id, :user_id])
    create index(:conversation_members, [:user_id], where: "left_at IS NULL")
    create index(:conversation_members, [:conversation_id], where: "left_at IS NULL")

    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :conversation_id,
          references(:conversations, type: :binary_id, on_delete: :delete_all),
          null: false

      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :author_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :body, :text
      add :reply_to_message_id, references(:messages, type: :binary_id, on_delete: :nilify_all)
      add :metadata, :map, null: false, default: %{}
      add :edited_at, :utc_datetime_usec
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:messages, [:conversation_id, :inserted_at],
             where: "deleted_at IS NULL",
             name: :messages_conversation_recent
           )

    create index(:messages, [:family_id])
  end
end
