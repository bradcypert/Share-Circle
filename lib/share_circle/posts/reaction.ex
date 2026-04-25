defmodule ShareCircle.Posts.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed_emoji ~w(👍 👎 ❤️ 😂 😮 😢 😡 🎉 🙏 🔥 👏 💯 🤔 😍 🥰 😊 🙌 💪 🤣 😭)
  @subject_types ~w(post comment message)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "reactions" do
    belongs_to :family, ShareCircle.Families.Family
    belongs_to :user, ShareCircle.Accounts.User
    field :subject_type, :string
    field :subject_id, :binary_id
    field :emoji, :string

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def allowed_emoji, do: @allowed_emoji

  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:subject_type, :subject_id, :emoji])
    |> validate_required([:subject_type, :subject_id, :emoji])
    |> validate_inclusion(:subject_type, @subject_types)
    |> validate_inclusion(:emoji, @allowed_emoji, message: "must be one of the supported emoji")
    |> unique_constraint([:user_id, :subject_type, :subject_id, :emoji])
  end
end
