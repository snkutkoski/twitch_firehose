defmodule TwitchApi.FetchActiveStreamsTest do
  use ExUnit.Case, async: true

  alias TwitchApi.FetchActiveStreams, as: Fetch
  alias TwitchApi.RateLimiter, as: RateLimiter
  alias TwitchApi.ChannelStore, as: Store

  setup do
    {:ok, rate_limiter} = RateLimiter.start_link
    {:ok, store} = Store.start_link
    {:ok, fetcher} = Fetch.start_link(rate_limiter, store)
    %{fetcher: fetcher, store: store, rate_limiter: rate_limiter}
  end

  test "when the process starts, it begins fetching every stream", %{store: store} do
    #TODO: Rate limiter add_handler that listens for dequeues so we don't need to sleep anymore in tests.
    :timer.sleep(2000) # Wait for the rate limiter.
    assert Store.all(store) == ["twitch_channel_name", "twitch_channel_name2"]
  end
end
