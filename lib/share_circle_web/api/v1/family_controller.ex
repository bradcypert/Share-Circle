defmodule ShareCircleWeb.Api.V1.FamilyController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Chat
  alias ShareCircle.Families
  alias ShareCircleWeb.Api.V1.{FamilyJSON, Response}

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  # POST /api/v1/families
  def create(conn, %{"family" => params}) do
    with {:ok, {family, _membership}} <- Families.create_family(conn.assigns.current_scope, params) do
      Chat.ensure_family_conversation(family.id)

      conn
      |> put_status(:created)
      |> Response.render_data(FamilyJSON.render(family))
    end
  end

  # GET /api/v1/families/:family_id  (LoadCurrentFamily already loaded it)
  def show(conn, _params) do
    Response.render_data(conn, FamilyJSON.render(conn.assigns.current_scope.family))
  end

  # PATCH /api/v1/families/:family_id
  def update(conn, %{"family" => params}) do
    with {:ok, family} <- Families.update_family(conn.assigns.current_scope, params) do
      Response.render_data(conn, FamilyJSON.render(family))
    end
  end

  # DELETE /api/v1/families/:family_id
  def delete(conn, _params) do
    with {:ok, _family} <- Families.delete_family(conn.assigns.current_scope) do
      send_resp(conn, :no_content, "")
    end
  end
end
