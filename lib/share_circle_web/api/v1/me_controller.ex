defmodule ShareCircleWeb.Api.V1.MeController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Accounts
  alias ShareCircle.Families
  alias ShareCircleWeb.Api.V1.{FamilyJSON, Response, UserJSON}

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  # GET /api/v1/me
  def show(conn, _params) do
    Response.render_data(conn, UserJSON.render(conn.assigns.current_scope.user))
  end

  # PATCH /api/v1/me
  def update(conn, %{"user" => params}) do
    with {:ok, updated} <- Accounts.update_user_profile(conn.assigns.current_scope.user, params) do
      Response.render_data(conn, UserJSON.render(updated))
    end
  end

  # DELETE /api/v1/me
  def delete(conn, _params) do
    {:ok, _user} = Accounts.soft_delete_user(conn.assigns.current_scope.user)
    send_resp(conn, :no_content, "")
  end

  # GET /api/v1/me/families
  def families(conn, _params) do
    memberships = Families.list_families_for_user(conn.assigns.current_scope)

    data =
      Enum.map(memberships, fn m ->
        Map.merge(FamilyJSON.render(m.family), %{
          role: m.role,
          nickname: m.nickname,
          joined_at: m.joined_at
        })
      end)

    Response.render_data(conn, data)
  end
end
