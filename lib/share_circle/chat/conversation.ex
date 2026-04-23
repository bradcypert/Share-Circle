defmodule ShareCircle.Chat.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_kinds ~w(family group direct)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "conversations" do
    field :kind, :string
    field :name, :string
    field :last_message_at, :utc_datetime_usec
    field :last_message_preview, :string
    field :deleted_at, :utc_datetime_usec

    belongs_to :family, ShareCircle.Families.Family
    belongs_to :created_by, ShareCircle.Accounts.User, foreign_key: :created_by_user_id
    has_many :members, ShareCircle.Chat.ConversationMember
    has_many :messages, ShareCircle.Chat.Message

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:family_id, :kind, :name, :created_by_user_id])
    |> validate_required([:family_id, :kind])
    |> validate_inclusion(:kind, @valid_kinds)
    |> validate_name_for_kind()
  end

  defp validate_name_for_kind(changeset) do
    case get_field(changeset, :kind) do
      "group" -> validate_required(changeset, [:name])
      _ -> changeset
    end
  end
end
