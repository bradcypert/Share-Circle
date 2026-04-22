defmodule ShareCircleWeb.Api.V1.InvitationController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Families
  alias ShareCircleWeb.Api.V1.{InvitationJSON, MemberJSON, Response}

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  # GET /api/v1/families/:family_id/invitations
  def index(conn, _params) do
    invitations = Families.list_invitations(conn.assigns.current_scope)
    Response.render_data(conn, Enum.map(invitations, &InvitationJSON.render/1))
  end

  # POST /api/v1/families/:family_id/invitations
  def create(conn, %{"invitation" => params}) do
    with {:ok, {invitation, _token}} <- Families.invite_member(conn.assigns.current_scope, params) do
      conn
      |> put_status(:created)
      |> Response.render_data(InvitationJSON.render(invitation))
    end
  end

  # DELETE /api/v1/families/:family_id/invitations/:id
  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- Families.revoke_invitation(conn.assigns.current_scope, id) do
      send_resp(conn, :no_content, "")
    end
  end

  # POST /api/v1/invitations/:token/accept
  def accept(conn, %{"token" => token}) do
    with {:ok, membership} <- Families.accept_invitation(token, conn.assigns.current_scope) do
      conn
      |> put_status(:created)
      |> Response.render_data(MemberJSON.render(membership))
    end
  end
end
