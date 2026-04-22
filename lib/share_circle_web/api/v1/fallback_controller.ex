defmodule ShareCircleWeb.Api.V1.FallbackController do
  use Phoenix.Controller, formats: [:json]

  alias ShareCircleWeb.Api.V1.Response

  def call(conn, {:error, :not_found}) do
    Response.render_error(conn, :not_found, "not_found", "Resource not found")
  end

  def call(conn, {:error, :unauthorized}) do
    Response.render_error(conn, :forbidden, "forbidden", "You are not allowed to do that")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    details =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, val}, acc ->
          String.replace(acc, "%{#{key}}", to_string(val))
        end)
      end)
      |> Enum.flat_map(fn {field, messages} ->
        Enum.map(messages, &%{field: to_string(field), message: &1})
      end)

    Response.render_error(
      conn,
      :unprocessable_entity,
      "validation_failed",
      "Validation failed",
      details
    )
  end
end
