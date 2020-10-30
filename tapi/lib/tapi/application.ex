defmodule Tapi.Application do
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    api_port = Application.get_env(:tapi, :api_port)

    children = [
      TapiWeb.Telemetry,
      {Phoenix.PubSub, name: Tapi.PubSub},
      TapiWeb.Endpoint,
      {Plug.Cowboy, scheme: :http, plug: TapiWeb.ApiRouter, options: [port: api_port]}
    ]

    Logger.info("Running TapiWeb.ApiRouter with cowboy 2.8.0 at 0.0.0.0:#{api_port}")

    opts = [strategy: :one_for_one, name: Tapi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TapiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
