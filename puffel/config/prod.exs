import Config

config :puffel, Puffel.Repo,
  database: "puffel",
  username: "postgres",
  password: "postgres",
  hostname: "db",
  port: "5432"
