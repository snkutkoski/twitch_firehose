defmodule TwitchApi.FetchActiveStreams do
  use GenServer

  @streams Application.get_env(:twitch_firehose, :streams_api)

  alias TwitchApi.RateLimiter, as: RateLimiter
  alias TwitchApi.ChannelStore, as: ChannelStore

  def start_link(rate_limiter, channel_store) do
    GenServer.start_link(__MODULE__, %{rate_limiter: rate_limiter, channel_store: channel_store})
  end

  def init(state) do
    fetch_init(self())
    {:ok, state}
  end

  def fetch_init(pid) do
    GenServer.cast(pid, :fetch_init)
  end

  def fetch_init_complete(pid, response) do
    GenServer.cast(pid, {:fetch_init_complete, response})
  end

  def handle_cast(:fetch_init, state) do
    pid = self()
    channel_store = state.channel_store
    RateLimiter.enqueue(
      state.rate_limiter,
      fn() ->
        @streams.live_streams(0)
      end,
      fn(response) ->
        save_channels(channel_store, response)
        fetch_init_complete(pid, response)
      end
    )
    {:noreply, state}
  end

  def handle_cast({:fetch_init_complete, response}, state) do
    enqueue_fetch_all(100, response["_total"], state.rate_limiter, state.channel_store)
    {:noreply, state}
  end

  defp enqueue_fetch_all(offset, total_active, rate_limiter, channel_store) do
    continue = offset < 200
    pid = self()

    RateLimiter.enqueue(
      rate_limiter,
      fn() ->
        @streams.live_streams(offset)
      end,
      fn(response) ->
        save_channels(channel_store, response)
        if !continue do
          ChannelStore.age(channel_store)
          fetch_init(pid)
        end
      end
    )

    if continue do
      enqueue_fetch_all(offset + 100, total_active, rate_limiter, channel_store)
    end
  end

  defp save_channels(channel_store, response) do
    Enum.each(response["streams"], fn(stream) ->
      ChannelStore.insert(channel_store, stream["channel"]["name"])
    end)
  end
end
