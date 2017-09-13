defmodule TwitchApi.ChannelStore do
  use GenServer

  alias TwitchApi.Channel, as: Channel

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def insert(pid, channel_name) do
    GenServer.call(pid, {:insert, channel_name})
  end

  def age(pid) do
    GenServer.call(pid, :age)
  end

  def join(pid, channel_name) do
    GenServer.call(pid, {:join, channel_name})
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def handle_call({:insert, channel_name}, _from, channels) do
    {new_channels, channel_found} = Enum.reduce(channels, {[], false}, fn(channel, {new_channels, channel_found}) ->
      if channel.name == channel_name do
        {[%Channel{name: channel_name, status: :fresh, joined: channel.joined} | new_channels], true}
      else
        {[channel | new_channels], channel_found}
      end
    end)

    new_channels = if channel_found do
      new_channels
    else
      [%Channel{name: channel_name} | new_channels]
    end

    {:reply, new_channels, new_channels}
  end

  def handle_call({:join, channel_name}, _from, channels) do
    new_channels = Enum.reduce(channels, [], fn(channel, new_channels) ->
      if channel.name == channel_name do
        [Channel.join(channel) | new_channels]
      else
        [channel | new_channels]
      end
    end)

    {:reply, new_channels, new_channels}
  end

  def handle_call(:age, _from, channels) do
    new_state = Channel.age_all(channels)
    {:reply, new_state, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end
