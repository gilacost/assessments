use Mix.Config

config :patick, ecto_repos: [Patick.Repo]

config :patick, Patick.Repo,
  database: "patick",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

import_config "#{Mix.env()}.exs"
