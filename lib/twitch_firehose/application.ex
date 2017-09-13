defmodule TwitchFirehose.Application do
  use Application

  @connection_handler Application.get_env(:twitch_firehose, :connection_handler)

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    {:ok, irc_client} = ExIrc.start_client!
    {:ok, api_rate_limiter} = TwitchApi.RateLimiter.start_link(1000)
    {:ok, channel_store} = TwitchApi.ChannelStore.start_link

    {:ok, irc_rate_limiter} = TwitchApi.RateLimiter.start_link(2000)

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(TwitchFirehoseWeb.Endpoint, []),
      worker(@connection_handler, [irc_client]),
      worker(TwitchApi.FetchActiveStreams, [api_rate_limiter, channel_store]),
      worker(TwitchFirehose.JoinChannels, [irc_rate_limiter, channel_store, irc_client])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitchFirehose.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitchFirehoseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
