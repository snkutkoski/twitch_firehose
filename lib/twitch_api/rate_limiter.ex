defmodule TwitchApi.RateLimiter do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :queue.new)
  end

  def init(queue) do
    :timer.apply_interval(:timer.seconds(1), __MODULE__, :tick, [self()])
    {:ok, queue}
  end

  # Client

  def enqueue(pid, api_call, on_success) do
    GenServer.cast(pid, {:enqueue, {api_call, on_success}})
  end

  def tick(pid) do
    case dequeue(pid) do
      :empty -> nil
      {api_call, on_success} ->
        {:ok, response} = api_call.()
        on_success.(response)
    end
  end

  defp dequeue(pid) do
    GenServer.call(pid, :dequeue)
  end

  # Callbacks

  def handle_cast({:enqueue, {api_call, on_success}}, queue) do
    {:noreply, :queue.in({api_call, on_success}, queue)}
  end

  def handle_call(:dequeue, _from, queue) do
    case :queue.out(queue) do
      {{:value, {api_call, on_success}}, new_queue} ->
        {:reply, {api_call, on_success}, new_queue}
      {:empty, new_queue} ->
        {:reply, :empty, new_queue}
    end
  end
end
