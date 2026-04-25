defmodule ShareCircle.Media.MediaVariant do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_kinds ~w(thumb_256 thumb_1024 video_720p hls_manifest)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "media_variants" do
    field :variant_kind, :string
    field :storage_key, :string
    field :mime_type, :string
    field :byte_size, :integer
    field :width, :integer
    field :height, :integer
    field :duration_ms, :integer

    belongs_to :media_item, ShareCircle.Media.MediaItem

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [
      :media_item_id,
      :variant_kind,
      :storage_key,
      :mime_type,
      :byte_size,
      :width,
      :height,
      :duration_ms
    ])
    |> validate_required([:media_item_id, :variant_kind, :storage_key, :mime_type, :byte_size])
    |> validate_inclusion(:variant_kind, @valid_kinds)
    |> unique_constraint([:media_item_id, :variant_kind])
  end
end
