defmodule TwitchApi.RateLimiterTest do
  use ExUnit.Case, async: true

  alias TwitchApi.RateLimiter, as: RateLimiter

  setup do
    {:ok, pid} = RateLimiter.start_link
    %{rate_limiter: pid}
  end

  test "The items in the queue are dequeued every second", %{rate_limiter: rate_limiter} do
    pid = self()
    RateLimiter.enqueue(
      rate_limiter,
      fn() -> {:ok, %{}} end,
      fn(_) -> send(pid, :test_message) end
    )

    # The timeout is 2 seconds (not 1) since a dequeue may have happened right before the first enqueue
    assert_receive(:test_message, 2000)
  end
end
