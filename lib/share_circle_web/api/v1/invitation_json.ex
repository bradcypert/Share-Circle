defmodule ShareCircleWeb.Api.V1.InvitationJSON do
  alias ShareCircle.Families.Invitation

  def render(%Invitation{} = inv) do
    %{
      id: inv.id,
      email: inv.email,
      role: inv.role,
      expires_at: inv.expires_at,
      inserted_at: inv.inserted_at
    }
  end
end
