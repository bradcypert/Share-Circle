defmodule ShareCircleWeb.Api.V1.MediaController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Media

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  def download(conn, %{"id" => media_id} = params) do
    scope = conn.assigns.current_scope
    variant_kind = Map.get(params, "variant")

    result =
      if variant_kind do
        Media.get_variant_url(scope, media_id, variant_kind)
      else
        Media.get_download_url(scope, media_id)
      end

    with {:ok, url} <- result do
      redirect(conn, external: url)
    end
  end
end
