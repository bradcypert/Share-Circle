defmodule ShareCircle.Repo.Migrations.CreatePostsCommentsReactions do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :author_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :kind, :string, null: false, default: "text"
      add :body, :text
      add :metadata, :map, null: false, default: %{}
      add :edited_at, :utc_datetime_usec
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:posts, [:family_id, :inserted_at],
             where: "deleted_at IS NULL",
             name: "posts_family_feed"
           )

    create index(:posts, [:author_id, :inserted_at])

    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :post_id, references(:posts, type: :binary_id, on_delete: :delete_all), null: false
      add :author_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :parent_comment_id,
          references(:comments, type: :binary_id, on_delete: :delete_all)

      add :body, :text, null: false
      add :edited_at, :utc_datetime_usec
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:comments, [:post_id, :inserted_at],
             where: "deleted_at IS NULL",
             name: "comments_post_id"
           )

    create index(:comments, [:family_id])

    create table(:reactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :family_id, references(:families, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :subject_type, :string, null: false
      add :subject_id, :binary_id, null: false
      add :emoji, :string, null: false

      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create unique_index(:reactions, [:user_id, :subject_type, :subject_id, :emoji])
    create index(:reactions, [:subject_type, :subject_id], name: "reactions_subject")
    create index(:reactions, [:family_id])
  end
end
