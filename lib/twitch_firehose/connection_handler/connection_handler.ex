defmodule TwitchFirehose.ConnectionHandler do
  defmodule State do
    defstruct host: Application.get_env(:twitch_firehose, :chat_host),
              port: 6667,
              pass: Application.get_env(:twitch_firehose, :chat_token),
              nick: Application.get_env(:twitch_firehose, :twitch_username),
              client_pid: nil
  end

  @doc "Prepares the handler to receive messages"
  @callback init(%State{}) :: {:ok, %State{}}

  @doc "Handles a connected message"
  @callback handle_info({:connected, String.t, String.t}, %State{}) :: {:noreply, %State{}}
  @doc "Handles any unknown message"
  @callback handle_info(String.t, %State{}) :: {:noreply, %State{}}

  defmacro __using__(_params) do
    quote do
      @behaviour TwitchFirehose.ConnectionHandler

      alias TwitchFirehose.ConnectionHandler.State, as: State

      @doc "Starts the handler process and stores the IRC client pid that will send messages to the handler"
      def start_link(client_pid, state \\ %State{}) do
        GenServer.start_link(__MODULE__, %{state | client_pid: client_pid})
      end
    end
  end
end
