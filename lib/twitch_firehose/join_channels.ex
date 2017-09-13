defmodule TwitchFirehose.JoinChannels do
  def start_link(rate_limiter, channel_store, irc_client) do
    GenServer.start_link(__MODULE__, %{rate_limiter: rate_limiter, channel_store: channel_store,  irc_client: irc_client})
  end

  def init(%{rate_limiter: rate_limiter, channel_store: channel_store, irc_client: irc_client}) do
    :timer.sleep(10000)
    join_channels(rate_limiter, channel_store, irc_client)
    {:ok, %{rate_limiter: rate_limiter, channel_store: channel_store, irc_client: irc_client}}
  end

  def join_channels(rate_limiter, channel_store, irc_client) do
    IO.puts "JOINING CHANNELS!!!"
    channels = TwitchApi.ChannelStore.state(channel_store)
    IO.inspect(channels)
    Enum.each(channels, fn(channel) -> TwitchFirehose.JoinChannels.join_channel(channel, rate_limiter, channel_store, irc_client) end)
  end

  def join_channel(channel, rate_limiter, channel_store, irc_client) do
    IO.puts "JOINING CHANNEL"
    IO.inspect(channel)

    TwitchApi.RateLimiter.enqueue(
      rate_limiter,
      fn() ->
        ExIrc.Client.join(irc_client, "##{channel.name}")
        {:ok, []}
      end,
      fn(_) ->
        TwitchApi.ChannelStore.join(channel_store, channel)
      end
    )
  end
end
