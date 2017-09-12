defmodule TwitchApi.StreamsTest do
  use ExUnit.Case

  import Mock

  test "Fetch live streams success" do
    with_mock HTTPoison, [get: fn(_url, _body, _options) -> {:ok, %{body: "{}", status_code: 200}} end] do
      {outcome, body} = TwitchApi.Streams.live_streams
      assert outcome == :ok
      assert body == %{}
    end
  end

  test "Fetch live streams failure" do
    with_mock HTTPoison, [get: fn(_url, _body, _options) -> {:ok, %{body: "{}", status_code: 400}} end] do
      {outcome, _message} = TwitchApi.Streams.live_streams
      assert outcome == :error
    end
  end
end
