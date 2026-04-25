defmodule ShareCircle.Media.MediaItem do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_kinds ~w(image video audio file)
  @valid_statuses ~w(pending processing ready failed)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "media_items" do
    field :kind, :string
    field :mime_type, :string
    field :storage_key, :string
    field :byte_size, :integer
    field :checksum, :string
    field :width, :integer
    field :height, :integer
    field :duration_ms, :integer
    field :original_filename, :string
    field :processing_status, :string, default: "pending"
    field :processing_error, :string
    field :metadata, :map, default: %{}
    field :deleted_at, :utc_datetime_usec

    belongs_to :family, ShareCircle.Families.Family
    belongs_to :uploader, ShareCircle.Accounts.User, foreign_key: :uploader_user_id
    has_many :variants, ShareCircle.Media.MediaVariant

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [
      :family_id,
      :uploader_user_id,
      :kind,
      :mime_type,
      :storage_key,
      :byte_size,
      :checksum,
      :width,
      :height,
      :duration_ms,
      :original_filename,
      :metadata
    ])
    |> validate_required([
      :family_id,
      :uploader_user_id,
      :kind,
      :mime_type,
      :storage_key,
      :byte_size,
      :checksum
    ])
    |> validate_inclusion(:kind, @valid_kinds)
  end

  def update_processing_changeset(item, status, opts \\ []) do
    item
    |> change(processing_status: status)
    |> then(fn cs ->
      case Keyword.get(opts, :error) do
        nil -> cs
        msg -> change(cs, processing_error: msg)
      end
    end)
    |> then(fn cs ->
      case Keyword.get(opts, :dimensions) do
        {w, h} -> change(cs, width: w, height: h)
        nil -> cs
      end
    end)
    |> validate_inclusion(:processing_status, @valid_statuses)
  end
end
