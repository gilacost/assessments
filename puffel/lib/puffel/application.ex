defmodule Puffel.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    project_id = 209_930_607_165
    topic_name = "puffel-dev-topic"
    subscription_name = "puffel-dev-subscription"
    Puffel.Metrics.setup()

    children = [
      {Puffel.Repo, []},
      {Plug.Cowboy, scheme: :http, plug: Puffel.Router, options: [port: 4001]},
      {Puffel.PubSub, [project_id, topic_name, subscription_name]}
    ]

    opts = [strategy: :one_for_one, name: Puffel.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Puffel.Metrics do
  def setup do
    Puffel.Metrics.PipelineInstrumenter.setup()
    Puffel.Metrics.PlugExporter.setup()
  end
end

defmodule Puffel.Metrics.PlugExporter do
  use Prometheus.PlugExporter
end

defmodule Puffel.Metrics.PipelineInstrumenter do
  use Prometheus.PlugPipelineInstrumenter

  def label_value(:request_path, conn) do
    conn.request_path
  end
end
