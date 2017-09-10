defmodule TwitchFirehose.ConnectionHandlerImpl do
  use TwitchFirehose.ConnectionHandler

  @doc "Add the handler to the IRC client and connect to the server"
  def init(state) do
    ExIrc.Client.add_handler(state.client_pid, self())
    ExIrc.Client.connect!(state.client_pid, state.host, state.port)
    {:ok, state}
  end

  @doc "Log in to the server once connected"
  def handle_info({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"
    ExIrc.Client.logon(state.client_pid, state.pass, state.nick, state.nick, state.nick)
    {:noreply, state}
  end

  @doc "Print unknown messages"
  def handle_info(msg, state) do
    debug("Received unknown messsage:")
    IO.inspect(msg)
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
