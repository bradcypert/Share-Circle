defmodule ShareCircleWeb.Api.V1.UserJSON do
  alias ShareCircle.Accounts.User

  def render(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      display_name: user.display_name,
      timezone: user.timezone,
      locale: user.locale,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at
    }
  end
end
