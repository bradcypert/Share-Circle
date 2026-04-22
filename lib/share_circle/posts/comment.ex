defmodule ShareCircle.Posts.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "comments" do
    belongs_to :family, ShareCircle.Families.Family
    belongs_to :post, ShareCircle.Posts.Post
    belongs_to :author, ShareCircle.Accounts.User
    belongs_to :parent_comment, __MODULE__
    field :body, :string
    field :edited_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 1, max: 2_000)
  end

  def update_changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 1, max: 2_000)
    |> put_change(:edited_at, DateTime.utc_now())
  end
end
