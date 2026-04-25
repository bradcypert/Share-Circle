defmodule ShareCircle.PubSub do
  @moduledoc """
  Topic conventions and helpers for Phoenix.PubSub.

  All topic strings are defined here to avoid duplication across
  channels, contexts, and LiveViews.
  """

  @pubsub __MODULE__

  # ---------------------------------------------------------------------------
  # Topics
  # ---------------------------------------------------------------------------

  def family_topic(family_id), do: "family:#{family_id}"
  def conversation_topic(conversation_id), do: "conversation:#{conversation_id}"
  def user_topic(user_id), do: "user:#{user_id}"

  # ---------------------------------------------------------------------------
  # Subscribe / broadcast
  # ---------------------------------------------------------------------------

  def subscribe(topic) when is_binary(topic) do
    Phoenix.PubSub.subscribe(@pubsub, topic)
  end

  def unsubscribe(topic) when is_binary(topic) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic)
  end

  def broadcast(topic, event, payload) when is_binary(topic) and is_atom(event) do
    Phoenix.PubSub.broadcast(@pubsub, topic, {event, payload})
  end
end
