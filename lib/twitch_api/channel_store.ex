defmodule TwitchApi.ChannelStore do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def insert(pid, channel) do
    GenServer.cast(pid, {:insert, channel})
  end

  def expire_store(pid) do
    GenServer.cast(pid, :expire_store)
  end

  def all(pid) do
    GenServer.call(pid, :all)
  end

  def handle_cast({:insert, channel}, state) do
    {:noreply, Map.put(state, channel, true)}
  end

  def handle_cast(:expire_store, state) do
    new_state = Enum.reduce(state, %{}, fn({channel, safe}, new_state) ->
      if safe do
        Map.put(new_state, channel, false)
      else
        new_state
      end
    end)

    {:noreply, new_state}
  end

  def handle_call(:all, _from, state) do
    {:reply, Map.keys(state), state}
  end
end
