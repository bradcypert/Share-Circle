defmodule ShareCircleWeb.Api.V1.ConversationController do
  use ShareCircleWeb, :controller

  alias ShareCircle.Chat

  action_fallback ShareCircleWeb.Api.V1.FallbackController

  def index(conn, _params) do
    conversations = Chat.list_conversations(conn.assigns.current_scope)
    json(conn, %{data: Enum.map(conversations, &render_conversation/1)})
  end

  def create(conn, params) do
    with {:ok, conversation} <- Chat.create_conversation(conn.assigns.current_scope, params) do
      conn
      |> put_status(:created)
      |> json(%{data: render_conversation(conversation)})
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, conversation} <- Chat.get_conversation(conn.assigns.current_scope, id) do
      json(conn, %{data: render_conversation(conversation)})
    end
  end

  defp render_conversation(conv) do
    %{
      id: conv.id,
      kind: conv.kind,
      name: conv.name,
      last_message_at: conv.last_message_at && DateTime.to_iso8601(conv.last_message_at),
      last_message_preview: conv.last_message_preview,
      members: Enum.map(conv.members, &render_member/1),
      inserted_at: DateTime.to_iso8601(conv.inserted_at)
    }
  end

  defp render_member(cm) do
    %{
      user_id: cm.user_id,
      display_name: cm.user.display_name,
      joined_at: DateTime.to_iso8601(cm.joined_at)
    }
  end
end
