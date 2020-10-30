defmodule Patick.Router do
  @moduledoc """
  Simple router that contain all the endpoints demanded per
  task. The logic is so simple that there is no need to
  implement a controller and split the logic.

  ## Endpoints:

    POST /api/tickets | creates a new ticket

    GET /api/tickets/:barcode | current ticket price

    POST /api/tickets/:barcode/payments | for paying a ticket

    GET /api/tickets/:barcode/state | paid or unpaid

    GET /api/free-spaces | returns the lot free spaces

  """
  use Plug.Router
  alias Patick.{Ticket, Repo, Http, PaymentMethodEnum}

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["text/*"],
    json_decoder: Jason

  plug(:match)
  plug(:dispatch)

  post "/api/tickets" do
    cond do
      Ticket.free_spaces() > 0 ->
        code = Ticket.create()
        Http.send_created(conn, %{code: code})

      true ->
        Http.send_locked(conn, "There are no free spaces")
    end
  end

  get "/api/tickets/:barcode" do
    Ticket
    |> Repo.get_by(code: barcode)
    |> case do
      %Ticket{} = ticket ->
        price = Ticket.calculate_price(ticket)
        Http.send_ok(conn, %{price: price})

      _ ->
        Http.send_not_found(conn, "Ticket with code #{barcode} does not exist")
    end
  end

  post "/api/tickets/:barcode/payments" do
    payment_method = Map.get(conn.params, "payment_method", nil)

    with true <- PaymentMethodEnum.valid_value?(payment_method),
         ticket = %Ticket{is_paid?: false} <- Repo.get_by(Ticket, code: barcode) do
      {:ok, ticket} = Ticket.pay(ticket, payment_method)
      Http.send_ok(conn, ticket)
    else
      false ->
        Http.send_bad(conn, "Payment method does not exists.")

      %Ticket{is_paid?: true} ->
        Http.send_bad(conn, "Ticket with code #{barcode} has been already paid")

      _ ->
        Http.send_not_found(conn, "Ticket with code #{barcode} does not exist")
    end
  end

  get "/api/tickets/:barcode/state" do
    with ticket = %Ticket{is_paid?: true} <- Repo.get_by(Ticket, code: barcode),
         true <- Ticket.allowed_to_leave?(ticket) do
      Http.send_ok(conn, %{state: "paid"})
    else
      _ ->
        Http.send_ok(conn, %{state: "unpaid"})
    end
  end

  get "/api/free-spaces" do
    Http.send_ok(conn, %{spaces: Ticket.free_spaces()})
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
