use Mix.Config

config :puffel, Puffel.Repo,
  username: "postgres",
  password: "postgres",
  database: "puffel_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
