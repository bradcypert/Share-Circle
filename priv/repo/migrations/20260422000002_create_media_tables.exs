defmodule ShareCircle.Repo.Migrations.CreateMediaTables do
  use Ecto.Migration

  def change do
    create table(:media_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :uploader_user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :kind, :string, null: false
      add :mime_type, :string, null: false
      add :storage_key, :string, null: false
      add :byte_size, :bigint, null: false
      add :checksum, :string, null: false
      add :width, :integer
      add :height, :integer
      add :duration_ms, :integer
      add :original_filename, :string
      add :processing_status, :string, null: false, default: "pending"
      add :processing_error, :string
      add :metadata, :map, null: false, default: %{}
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:media_items, [:family_id])
    create index(:media_items, [:uploader_user_id])
    create index(:media_items, [:processing_status], where: "processing_status IN ('pending', 'processing')")

    create table(:media_variants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :media_item_id, references(:media_items, type: :binary_id, on_delete: :delete_all), null: false
      add :variant_kind, :string, null: false
      add :storage_key, :string, null: false
      add :mime_type, :string, null: false
      add :byte_size, :bigint, null: false
      add :width, :integer
      add :height, :integer
      add :duration_ms, :integer

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create unique_index(:media_variants, [:media_item_id, :variant_kind])

    create table(:upload_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :storage_key, :string, null: false
      add :expected_byte_size, :bigint, null: false
      add :expected_mime_type, :string
      add :expires_at, :utc_datetime_usec, null: false
      add :completed_at, :utc_datetime_usec
      add :media_item_id, references(:media_items, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:upload_sessions, [:expires_at], where: "completed_at IS NULL")

    create table(:post_media, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :post_id, references(:posts, type: :binary_id, on_delete: :delete_all), null: false
      add :media_item_id, references(:media_items, type: :binary_id, on_delete: :delete_all), null: false
      add :position, :integer, null: false
      add :caption, :string

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create unique_index(:post_media, [:post_id, :media_item_id])
    create unique_index(:post_media, [:post_id, :position])
    create index(:post_media, [:post_id])
  end
end
