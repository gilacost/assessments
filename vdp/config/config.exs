use Mix.Config

config :vdp, Vdp.Repo,
  database: "vdp",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :vdp, ecto_repos: [Vdp.Repo]
