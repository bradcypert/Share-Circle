defmodule ShareCircle.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias ShareCircle.Accounts.User
  alias ShareCircle.Families.Family

  @kinds ~w(text photo video album link)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "posts" do
    belongs_to :family, Family
    belongs_to :author, User
    field :kind, :string, default: "text"
    field :body, :string
    field :metadata, :map, default: %{}
    field :edited_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec

    has_many :comments, ShareCircle.Posts.Comment
    has_many :post_media, ShareCircle.Media.PostMedia

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:kind, :body, :metadata])
    |> validate_required([:kind])
    |> validate_inclusion(:kind, @kinds, message: "must be one of: #{Enum.join(@kinds, ", ")}")
    |> validate_length(:body, max: 10_000)
  end

  def update_changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :metadata])
    |> validate_length(:body, max: 10_000)
    |> put_change(:edited_at, DateTime.utc_now())
  end
end
