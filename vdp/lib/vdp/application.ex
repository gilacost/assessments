defmodule Vdp.Application do
  @moduledoc false
  @ets_opts [:set, :named_table, :public, read_concurrency: true]

  use Application

  def start(_type, _args) do
    :ets.new(:searches_bucket, @ets_opts)

    children = [
      {Plug.Cowboy, scheme: :http, plug: Vdp.Router, options: [port: 8080]},
      {Vdp.Repo, []}
    ]

    opts = [strategy: :one_for_one, name: Vdp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
