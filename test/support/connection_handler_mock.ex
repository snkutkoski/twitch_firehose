defmodule TwitchFirehose.ConnectionHandlerMock do
  use TwitchFirehose.ConnectionHandler

  def init(state) do
    {:ok, state}
  end

  def handle_info({:connected, _server, _port}, state) do
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
