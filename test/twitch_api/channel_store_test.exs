defmodule TwitchApi.ChannelStoreTest do
  use ExUnit.Case, async: true

  alias TwitchApi.ChannelStore, as: Store

  setup do
    {:ok, store} = Store.start_link
    %{store: store}
  end

  test "insert new channel", %{store: store} do
    Store.insert(store, "twitch_channel")
    assert Store.all(store) == ["twitch_channel"]
  end

  test "expire_store removes channels that have existed since the previous call to expire_store", %{store: store} do
    Store.insert(store, "channel1")
    Store.insert(store, "channel2")
    Store.expire_store(store)
    Store.insert(store, "channel3")
    Store.expire_store(store)
    assert Store.all(store) == ["channel3"]
  end

  test "expire_store does not remove channels that were re-inserted after the latest expire_store", %{store: store} do
    Store.insert(store, "channel1")
    Store.insert(store, "channel2")
    Store.expire_store(store)
    Store.insert(store, "channel2")
    Store.expire_store(store)
    assert Store.all(store) == ["channel2"]
  end
end
