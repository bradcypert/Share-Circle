defmodule ShareCircleWeb.Api.V1.UploadController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Media

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  def init_upload(conn, %{"family_id" => _} = params) do
    scope = conn.assigns.current_scope

    with {:ok, {session, put_result}} <- Media.initiate_upload(scope, params) do
      conn
      |> put_status(:created)
      |> json(%{
        data: %{
          upload_id: session.id,
          upload_url: put_result.upload_url,
          method: put_result.method,
          headers: put_result.headers,
          expires_at: DateTime.to_iso8601(put_result.expires_at)
        }
      })
    end
  end

  def complete_upload(conn, %{"upload_id" => upload_id}) do
    scope = conn.assigns.current_scope

    with {:ok, media_item} <- Media.complete_upload(scope, upload_id) do
      conn
      |> put_status(:created)
      |> json(%{data: render_media_item(media_item)})
    end
  end

  defp render_media_item(item) do
    %{
      id: item.id,
      kind: item.kind,
      mime_type: item.mime_type,
      byte_size: item.byte_size,
      processing_status: item.processing_status,
      inserted_at: DateTime.to_iso8601(item.inserted_at)
    }
  end
end
