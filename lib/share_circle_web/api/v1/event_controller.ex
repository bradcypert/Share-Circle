defmodule ShareCircleWeb.Api.V1.EventController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Calendar
  alias ShareCircleWeb.Api.V1.{EventJSON, Response}

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  def index(conn, params) do
    scope = conn.assigns.current_scope
    opts = build_opts(params)
    events = Calendar.list_events(scope, opts)
    Response.render_collection(conn, Enum.map(events, &EventJSON.render/1), %{})
  end

  def create(conn, %{"event" => attrs}) do
    scope = conn.assigns.current_scope

    with {:ok, event} <- Calendar.create_event(scope, attrs) do
      Response.render_data(conn, EventJSON.render(event), :created)
    end
  end

  def show(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, event} <- Calendar.get_event(scope, id) do
      my_rsvp = Calendar.get_my_rsvp(scope, id)
      Response.render_data(conn, EventJSON.render(event, my_rsvp))
    end
  end

  def update(conn, %{"id" => id, "event" => attrs}) do
    scope = conn.assigns.current_scope

    with {:ok, event} <- Calendar.update_event(scope, id, attrs) do
      my_rsvp = Calendar.get_my_rsvp(scope, id)
      Response.render_data(conn, EventJSON.render(event, my_rsvp))
    end
  end

  def delete(conn, %{"id" => id}) do
    scope = conn.assigns.current_scope

    with {:ok, _event} <- Calendar.delete_event(scope, id) do
      send_resp(conn, :no_content, "")
    end
  end

  defp build_opts(params) do
    []
    |> maybe_put(:from, params["from"], &parse_dt/1)
    |> maybe_put(:to, params["to"], &parse_dt/1)
  end

  defp maybe_put(opts, _key, nil, _), do: opts

  defp maybe_put(opts, key, val, parser) do
    case parser.(val) do
      nil -> opts
      parsed -> Keyword.put(opts, key, parsed)
    end
  end

  defp parse_dt(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end
end
