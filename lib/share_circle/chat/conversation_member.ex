defmodule ShareCircle.Chat.ConversationMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "conversation_members" do
    field :joined_at, :utc_datetime_usec
    field :last_read_message_id, :binary_id
    field :muted_until, :utc_datetime_usec
    field :left_at, :utc_datetime_usec

    belongs_to :conversation, ShareCircle.Chat.Conversation
    belongs_to :user, ShareCircle.Accounts.User
    belongs_to :family, ShareCircle.Families.Family

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:conversation_id, :user_id, :family_id, :joined_at])
    |> validate_required([:conversation_id, :user_id, :family_id, :joined_at])
    |> unique_constraint([:conversation_id, :user_id])
  end

  def mark_read_changeset(member, message_id) do
    change(member, last_read_message_id: message_id)
  end
end
