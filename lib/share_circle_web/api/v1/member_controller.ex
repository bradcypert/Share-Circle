defmodule ShareCircleWeb.Api.V1.MemberController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Families
  alias ShareCircleWeb.Api.V1.{MemberJSON, Response}

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  # GET /api/v1/families/:family_id/members
  def index(conn, _params) do
    members = Families.list_members(conn.assigns.current_scope)
    Response.render_data(conn, Enum.map(members, &MemberJSON.render/1))
  end

  # PATCH /api/v1/families/:family_id/members/:user_id
  def update(conn, %{"user_id" => user_id, "member" => %{"role" => role}}) do
    with {:ok, membership} <-
           Families.update_member_role(conn.assigns.current_scope, user_id, role) do
      Response.render_data(conn, MemberJSON.render(membership))
    end
  end

  # DELETE /api/v1/families/:family_id/members/:user_id
  def delete(conn, %{"user_id" => user_id}) do
    with {:ok, _} <- Families.remove_member(conn.assigns.current_scope, user_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
