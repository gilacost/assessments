defmodule TapiWeb.Telemetry do
  @moduledoc """
  The telemetry supervisor.

  To enable event reporting in the console, uncomment the
  `Console.Metrics.Reporter` child in the `init/1` function.

  """
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 2_500}
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Returns a list of telemetry summaries that will be used to
  display the request duration along with some vm stats in
  the dashboard.
  """
  @spec metrics :: [%Telemetry.Metrics.Summary{}]
  def metrics do
    [
      # Api metrics
      summary("tapi_web.api_router.stop.duration",
        tags: [:route],
        tag_values: &get_and_put_route/1,
        unit: {:native, :millisecond}
      ),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {TapiWeb, :count_users, []}
    ]
  end

  @spec get_and_put_route(map) :: map
  defp get_and_put_route(%{conn: %{private: %{plug_route: {plug_route, _}}}} = metadata) do
    Map.put(metadata, :route, plug_route)
  end
end
