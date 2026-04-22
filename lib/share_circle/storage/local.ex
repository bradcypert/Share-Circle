defmodule ShareCircle.Storage.Local do
  @moduledoc """
  Local filesystem storage adapter for development and self-hosted deployments.

  Files are stored in the configured path directory. Upload and download URLs
  are signed Phoenix tokens that route through the LocalBlobController.
  """

  @behaviour ShareCircle.Storage

  @upload_ttl_seconds 3600
  @download_ttl_seconds 300

  @impl true
  def presigned_put(storage_key, _mime_type, _byte_size) do
    token = sign_token(%{key: storage_key, action: "put"}, @upload_ttl_seconds)
    url = ShareCircleWeb.Endpoint.url() <> "/api/v1/local-blob/#{token}"

    {:ok,
     %{
       upload_url: url,
       method: "PUT",
       headers: %{},
       expires_at: DateTime.add(DateTime.utc_now(), @upload_ttl_seconds, :second)
     }}
  end

  @impl true
  def presigned_get(storage_key, ttl_seconds) do
    token = sign_token(%{key: storage_key, action: "get"}, ttl_seconds)
    url = ShareCircleWeb.Endpoint.url() <> "/api/v1/local-blob/#{token}"
    {:ok, url}
  end

  @impl true
  def head(storage_key) do
    path = full_path(storage_key)

    case File.stat(path) do
      {:ok, %{size: size}} -> {:ok, %{byte_size: size}}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def delete(storage_key) do
    path = full_path(storage_key)

    case File.rm(path) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def store(storage_key, data) when is_binary(data) do
    path = full_path(storage_key)
    :ok = File.mkdir_p!(Path.dirname(path))
    File.write(path, data)
  end

  def read(storage_key) do
    File.read(full_path(storage_key))
  end

  def full_path(storage_key) do
    base = Application.fetch_env!(:share_circle, __MODULE__)[:path]
    Path.join(base, storage_key)
  end

  defp sign_token(payload, ttl) do
    Phoenix.Token.sign(
      ShareCircleWeb.Endpoint,
      "local_blob",
      payload,
      max_age: ttl
    )
  end

  def verify_token(token, max_age \\ @download_ttl_seconds) do
    Phoenix.Token.verify(ShareCircleWeb.Endpoint, "local_blob", token, max_age: max_age)
  end
end
