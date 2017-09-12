defmodule TwitchFirehose.Application do
  use Application

  @connection_handler Application.get_env(:twitch_firehose, :connection_handler)

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    {:ok, client} = ExIrc.start_client!
    {:ok, rate_limiter} = TwitchApi.RateLimiter.start_link
    {:ok, channel_store} = TwitchApi.ChannelStore.start_link

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(TwitchFirehoseWeb.Endpoint, []),
      worker(@connection_handler, [client]),
      worker(TwitchApi.FetchActiveStreams, [rate_limiter, channel_store])
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
