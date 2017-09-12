use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :twitch_firehose, TwitchFirehoseWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :twitch_firehose, :connection_handler, TwitchFirehose.ConnectionHandlerMock
config :twitch_firehose, :chat_token, "test_token"
config :twitch_firehose, :twitch_username, "test_username"
config :twitch_firehose, :chat_host, "test.irc.host"
config :twitch_firehose, :client_id, System.get_env("TWITCH_CLIENT_ID")
config :twitch_firehose, :streams_api, TwitchApi.StreamsMock
