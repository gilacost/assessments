defmodule Puffel do
  @doc "Checks if the application's pub/sub generic server is running."
  @spec healthcheck() :: :ok
  def healthcheck() do
    if get_endpoint_status() == :stopped, do: IO.puts("1"), else: IO.puts("0")
  end

  @spec get_endpoint_status() :: :running | :stopped | :unknown
  defp get_endpoint_status() do
    if Process.whereis(Puffel.PubSub) != nil, do: :running, else: :stopped
  end
end
