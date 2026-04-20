defmodule ShareCircle.Scope do
  @moduledoc """
  Carries the authenticated context for a request or process.

  Every context function accepts a Scope as its first argument. Queries
  automatically filter by `current_family`, and commands verify permissions
  via `current_membership.role`.
  """

  defstruct [:current_user, :current_family, :current_membership, :request_id]

  @type t :: %__MODULE__{
          current_user: ShareCircle.Accounts.User.t() | nil,
          current_family: ShareCircle.Families.Family.t() | nil,
          current_membership: ShareCircle.Families.Membership.t() | nil,
          request_id: String.t() | nil
        }

  @doc "Builds a scope for an authenticated user and family membership."
  def new(user, family, membership, request_id \\ nil) do
    %__MODULE__{
      current_user: user,
      current_family: family,
      current_membership: membership,
      request_id: request_id
    }
  end

  @doc "Returns true if the scope has an authenticated user."
  def authenticated?(%__MODULE__{current_user: nil}), do: false
  def authenticated?(%__MODULE__{}), do: true

  @doc "Returns true if the scope has a loaded family context."
  def in_family?(%__MODULE__{current_family: nil}), do: false
  def in_family?(%__MODULE__{}), do: true
end
