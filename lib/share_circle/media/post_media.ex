defmodule ShareCircle.Media.PostMedia do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "post_media" do
    field :position, :integer
    field :caption, :string

    belongs_to :post, ShareCircle.Posts.Post
    belongs_to :media_item, ShareCircle.Media.MediaItem

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:post_id, :media_item_id, :position, :caption])
    |> validate_required([:post_id, :media_item_id, :position])
    |> unique_constraint([:post_id, :media_item_id])
    |> unique_constraint([:post_id, :position])
  end
end
