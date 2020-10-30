defmodule ExampleInstrumenter do
  use Prometheus.Metric

  def setup do
    Histogram.new(
      name: :http_request_duration_milliseconds,
      labels: [:method],
      buckets: [100, 300, 500, 750, 1000],
      help: "Http Request execution time"
    )
  end

  def instrument(%{time: time, method: method}) do
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [method]], time)
  end
end
