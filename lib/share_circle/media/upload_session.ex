defmodule ShareCircle.Media.UploadSession do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "upload_sessions" do
    field :storage_key, :string
    field :expected_byte_size, :integer
    field :expected_mime_type, :string
    field :expires_at, :utc_datetime_usec
    field :completed_at, :utc_datetime_usec

    belongs_to :family, ShareCircle.Families.Family
    belongs_to :user, ShareCircle.Accounts.User
    belongs_to :media_item, ShareCircle.Media.MediaItem

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [
      :family_id,
      :user_id,
      :storage_key,
      :expected_byte_size,
      :expected_mime_type,
      :expires_at
    ])
    |> validate_required([:family_id, :user_id, :storage_key, :expected_byte_size, :expires_at])
  end

  def complete_changeset(session, media_item_id) do
    session
    |> change(completed_at: DateTime.utc_now(), media_item_id: media_item_id)
  end
end
