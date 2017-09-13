defmodule TwitchApi.Channel do
  defstruct name: nil, status: :fresh, joined: false

  alias TwitchApi.Channel, as: Channel

  def filter_joined(channels) do
    Enum.filter(channels, fn(channel) -> channel.joined end)
  end

  def filter_active(channels) do
    Enum.filter(channels, fn(channel) -> channel.status != :inactive end)
  end

  def join(channel) do
    %Channel{name: channel.name, status: channel.status, joined: true}
  end

  def join_all(channels) do
    Enum.map(channels, fn(channel) -> join(channel) end)
  end

  def age(channel) do
    new_status = case channel.status do
      :fresh -> :old
      :old -> :inactive
      _ -> channel.status
    end

    new_joined = new_status != :inactive && channel.joined

    %Channel{name: channel.name, status: new_status, joined: new_joined}
  end

  def age_all(channels) do
    Enum.map(channels, fn(channel) -> age(channel) end)
  end
end
