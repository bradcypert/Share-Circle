defmodule ShareCircle.RateLimiter do
  @moduledoc """
  ETS-backed sliding window rate limiter.

  Each bucket is identified by a key (e.g. {:auth, ip} or {:write, user_id}).
  Buckets automatically reset after their window expires.
  """

  use GenServer

  @table :rate_limiter
  @cleanup_interval_ms 60_000

  # Limits per window (requests, seconds)
  @limits %{
    auth: {10, 60},
    write: {60, 60},
    read: {600, 60},
    upload: {20, 60}
  }

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Checks whether the given key is within its rate limit.
  Returns :ok or {:error, :rate_limited}.
  """
  def check(bucket_type, key) do
    {limit, window_secs} = Map.fetch!(@limits, bucket_type)
    now = System.system_time(:second)
    ets_key = {bucket_type, key}

    case :ets.lookup(@table, ets_key) do
      [{^ets_key, count, window_start}] when now - window_start < window_secs ->
        if count < limit do
          :ets.update_counter(@table, ets_key, {2, 1})
          :ok
        else
          {:error, :rate_limited}
        end

      _ ->
        :ets.insert(@table, {ets_key, 1, now})
        :ok
    end
  end

  # GenServer callbacks

  @impl true
  def init(_) do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true, write_concurrency: true])
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    now = System.system_time(:second)

    # Remove buckets whose window has fully expired (max window is 60s, give 2x buffer)
    :ets.select_delete(@table, [
      {{{:_, :_}, :_, :"$1"}, [{:<, :"$1", now - 120}], [true]}
    ])

    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval_ms)
  end
end
