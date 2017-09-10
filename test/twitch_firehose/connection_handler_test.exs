defmodule TwitchFirehose.ConnectionHandlerTest do
  use ExUnit.Case, async: true

  import Mock

  alias TwitchFirehose.ConnectionHandler.State, as: State
  alias TwitchFirehose.ConnectionHandlerImpl, as: Handler

  setup do
    {
      :ok,
      handler_state: %State{
        host: "test_host",
        port: 6667,
        pass: "test_pass",
        nick: "test_nick"
      }
    }
  end

  test "adds itself as a handler to the IRC client and connects the client to the host/port", %{handler_state: state} do
    with_mock ExIrc.Client, [
      add_handler: fn(_client, handler) -> [handler] end,
      connect!: fn(_client, _host, _port) -> :ok end
    ] do
      Handler.init(state)
      assert called ExIrc.Client.add_handler(:_, :_)
      assert called ExIrc.Client.connect!(:_, state.host, state.port)
    end
  end

  test "logs in once connected to the IRC server", %{handler_state: state} do
    with_mock ExIrc.Client, [
      logon: fn(_client, _pass, _nick, _user, _name) -> :ok end
    ] do
      Handler.handle_info({:connected, state.host, state.port}, state)
      assert called ExIrc.Client.logon(:_, state.pass, state.nick, state.nick, state.nick)
    end
  end
end
