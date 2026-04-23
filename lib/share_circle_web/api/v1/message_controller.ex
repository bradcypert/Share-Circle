defmodule ShareCircleWeb.Api.V1.MessageController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Chat

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  def index(conn, %{"conversation_id" => conv_id} = params) do
    opts = [
      limit: parse_int(params["limit"], 50),
      cursor: params["cursor"]
    ]

    with {:ok, {messages, pagination}} <- Chat.list_messages(conn.assigns.current_scope, conv_id, opts) do
      json(conn, %{
        data: Enum.map(messages, &render_message/1),
        meta: pagination
      })
    end
  end

  def create(conn, %{"conversation_id" => conv_id} = params) do
    with {:ok, message} <- Chat.send_message(conn.assigns.current_scope, conv_id, params) do
      conn
      |> put_status(:created)
      |> json(%{data: render_message(message)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, message} <- Chat.update_message(conn.assigns.current_scope, id, params) do
      json(conn, %{data: render_message(message)})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- Chat.delete_message(conn.assigns.current_scope, id) do
      send_resp(conn, :no_content, "")
    end
  end

  def mark_read(conn, %{"conversation_id" => conv_id} = params) do
    with {:ok, _} <- Chat.mark_read(conn.assigns.current_scope, conv_id, params["last_read_message_id"]) do
      send_resp(conn, :no_content, "")
    end
  end

  defp render_message(msg) do
    %{
      id: msg.id,
      conversation_id: msg.conversation_id,
      body: msg.body,
      author: %{
        id: msg.author.id,
        display_name: msg.author.display_name
      },
      reply_to_message_id: msg.reply_to_message_id,
      edited_at: msg.edited_at && DateTime.to_iso8601(msg.edited_at),
      inserted_at: DateTime.to_iso8601(msg.inserted_at)
    }
  end

  defp parse_int(nil, default), do: default
  defp parse_int(val, _default), do: String.to_integer(val)
end
