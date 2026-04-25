defmodule ShareCircle.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "messages" do
    field :body, :string
    field :metadata, :map, default: %{}
    field :edited_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec

    belongs_to :conversation, ShareCircle.Chat.Conversation
    belongs_to :family, ShareCircle.Families.Family
    belongs_to :author, ShareCircle.Accounts.User
    belongs_to :reply_to, ShareCircle.Chat.Message, foreign_key: :reply_to_message_id

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [
      :conversation_id,
      :family_id,
      :author_id,
      :body,
      :reply_to_message_id,
      :metadata
    ])
    |> validate_required([:conversation_id, :family_id, :author_id])
    |> validate_body_or_media()
    |> validate_length(:body, max: 4000)
  end

  def update_changeset(message, attrs) do
    message
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, max: 4000)
    |> put_change(:edited_at, DateTime.utc_now())
  end

  defp validate_body_or_media(changeset) do
    body = get_field(changeset, :body)

    if is_nil(body) or String.trim(body) == "" do
      add_error(changeset, :body, "can't be blank")
    else
      changeset
    end
  end
end
