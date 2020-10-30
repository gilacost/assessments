defmodule TapiWeb.ApiRouter do
  @moduledoc """
  Api router with the three required routes.
  It has been kept separate from the phoenix app router to
  keep the implementation as minimal as possible and to
  ensure ownership while testing the telemetry plug.

  ## Routes

     GET `/accounts`
     GET `/accounts/:account_id`
     GET `/accounts/:account_id/transactions`

  ## Telemetry

  Telemetry plug has been added to produce a duration event
  that is displayed in a phoenix live dashboard.

  ## Basic auth plug

  Gathers the user from the Bearer.

  """

  use Plug.Router
  alias TapiWeb.Http
  alias Tapi.Models.{Account, Transaction}

  plug :match
  plug Plug.Telemetry, event_prefix: [:tapi_web, :api_router]
  plug TapiWeb.BasicAuth
  plug TapiWeb.HttpCache
  plug :dispatch

  get "/accounts" do
    accounts = Account.build_for_seed(conn.assigns[:seeds], true)
    Http.send_ok(conn, accounts)
  end

  get "/accounts/:account_id" do
    account =
      conn.assigns[:seeds]
      |> Account.build_for_seed(true)
      |> Enum.find(&(&1.id == account_id))

    if account do
      Http.send_ok(conn, account)
    else
      Http.send_not_found(conn)
    end
  end

  get "/accounts/:account_id/transactions" do
    account =
      conn.assigns[:seeds]
      |> Account.build_for_seed(false)
      |> Enum.find(&(&1.id == account_id))

    if account do
      transactions = Transaction.build_for_account(account)
      Http.send_ok(conn, transactions)
    else
      Http.send_not_found(conn)
    end
  end

  match _ do
    send_resp(conn, :not_found, "oops")
  end
end
