defmodule ShareCircle.Storage do
  @moduledoc """
  Behaviour for object storage adapters (local filesystem or S3-compatible).

  Configure via:
    config :share_circle, :storage_adapter, ShareCircle.Storage.Local
  """

  @type storage_key :: String.t()
  @type put_result :: %{
          upload_url: String.t(),
          method: String.t(),
          headers: map(),
          expires_at: DateTime.t()
        }

  @callback presigned_put(storage_key(), String.t(), non_neg_integer()) ::
              {:ok, put_result()} | {:error, term()}

  @callback presigned_get(storage_key(), non_neg_integer()) ::
              {:ok, String.t()} | {:error, term()}

  @callback head(storage_key()) ::
              {:ok, %{byte_size: non_neg_integer()}} | {:error, term()}

  @callback delete(storage_key()) :: :ok | {:error, term()}

  def adapter do
    Application.fetch_env!(:share_circle, :storage_adapter)
  end

  def presigned_put(key, mime_type, byte_size),
    do: adapter().presigned_put(key, mime_type, byte_size)

  def presigned_get(key, ttl_seconds \\ 300),
    do: adapter().presigned_get(key, ttl_seconds)

  def head(key), do: adapter().head(key)

  def delete(key), do: adapter().delete(key)

  @doc "Generates a storage key for a new upload."
  def new_key(family_id, mime_type) do
    ext = MIME.extensions(mime_type) |> List.first("bin")
    id = Ecto.UUID.generate()
    {year, month, _day} = Date.utc_today() |> Date.to_erl()
    "families/#{family_id}/#{year}/#{month}/#{id}.#{ext}"
  end
end
