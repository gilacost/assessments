use Mix.Config

config :patick, Patick.Repo,
  database: "patick_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432",
  pool: Ecto.Adapters.SQL.Sandbox

config :patick, :port, "4001"
