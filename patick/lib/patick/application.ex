defmodule Patick.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    {port, ""} = Application.get_env(:patick, :port) |> Integer.parse()

    children = [
      {Patick.Repo, []},
      {Plug.Cowboy, scheme: :http, plug: Patick.Router, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: Patick.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
