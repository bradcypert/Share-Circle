defmodule ShareCircleWeb.Api.V1.MemberJSON do
  alias ShareCircle.Families.Membership

  def render(%Membership{} = m) do
    %{
      user_id: m.user_id,
      display_name: m.user && m.user.display_name,
      email: m.user && m.user.email,
      role: m.role,
      nickname: m.nickname,
      joined_at: m.joined_at
    }
  end
end
