import Config

config :puffel, ecto_repos: [Puffel.Repo]

config :goth,
  json: "priv/account.json" |> File.read!()

config :puffel, Puffel.Repo,
  database: "puffel",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :prometheus, Puffel.Metrics.PipelineInstrumenter,
  labels: [:status_class, :method, :host, :scheme, :request_path],
  duration_buckets: [
    10,
    100,
    1_000,
    10_000,
    100_000,
    300_000,
    500_000,
    750_000,
    1_000_000,
    1_500_000,
    2_000_000,
    3_000_000
  ],
  registry: :default,
  duration_unit: :microseconds

import_config "#{Mix.env()}.exs"
