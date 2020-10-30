defmodule TapiWeb.Router do
  @moduledoc """
  The router for the phoenix app with the live dashboard.

  ## Routes

     GET `/dashboard`
  """

  use TapiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through :browser
    live_dashboard "/dashboard", metrics: TapiWeb.Telemetry
  end
end
