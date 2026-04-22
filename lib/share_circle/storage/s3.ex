defmodule ShareCircle.Storage.S3 do
  @moduledoc "S3-compatible storage adapter. Requires ex_aws + ex_aws_s3 deps."

  @behaviour ShareCircle.Storage

  @impl true
  def presigned_put(_key, _mime_type, _byte_size), do: {:error, :not_implemented}

  @impl true
  def presigned_get(_key, _ttl), do: {:error, :not_implemented}

  @impl true
  def head(_key), do: {:error, :not_implemented}

  @impl true
  def delete(_key), do: {:error, :not_implemented}
end
