defmodule TwitchApi.Streams do
  @url "https://api.twitch.tv/kraken/streams/"
  @client_id Application.get_env(:twitch_firehose, :client_id)

  def live_streams(offset \\ 0) do
    case HTTPoison.get(@url, [], params: %{
      client_id: @client_id,
      limit: 100,
      offset: offset
    }) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body)}
      _ ->
        {:error, "Twitch API call failed"}
    end
  end
end
