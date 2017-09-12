defmodule TwitchApi.StreamsMock do
  def live_streams(offset \\ 0) do
    {:ok, %{
      "streams" =>
        [
          %{"channel" => %{"name" => "twitch_channel_name"}},
          %{"channel" => %{"name" => "twitch_channel_name2"}}
        ],
      "_total" => 150
    }}
  end
end
