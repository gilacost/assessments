defmodule PatickChallengeTest do
  use ExUnit.Case, async: true
  use Patick.RepoCase
  use Plug.Test
  alias Patick.Router

  doctest Patick.PaymentMethodEnum

  @opts Router.init([])

  describe "Task 1 | POST /api/tickets" do
    test "creates 16 hex code and it is saved and returned" do
      conn = conn(:post, "/api/tickets")

      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 201
      assert {:ok, %{"code" => <<code::binary-size(16)>>}} = Jason.decode(conn.resp_body)
      refute Base.decode16(code, case: :lower) == :error
      assert %{code: code} = Repo.get_by(Ticket, code: code)
    end
  end

  describe "Task 2 | GET /api/tickets/:barcode" do
    test "calculates the price for a ticket creation time" do
      code = "know_code"

      two_hours_ago = naive_date_time(-(60 * 60 * 2))
      %Ticket{inserted_at: two_hours_ago, code: code} |> Repo.insert()

      conn = conn(:get, "/api/tickets/#{code}")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert {:ok, %{"price" => 4}} == Jason.decode(conn.resp_body)
    end

    test "if already paid returns price 0" do
      code = "paid_code"

      %Ticket{code: code, is_paid?: true} |> Repo.insert()

      conn = conn(:get, "/api/tickets/#{code}")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert {:ok, %{"price" => 0}} == Jason.decode(conn.resp_body)
    end
  end

  describe "Task 3 | POST /api/tickets/:barcode/payments" do
    test "valid payment method sets ticket as paid in time" do
      code = "to_pay_code"

      Repo.insert(%Ticket{code: code})
      Process.sleep(1000)

      conn = conn(:post, "/api/tickets/#{code}/payments", %{"payment_method" => "cash"})
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200

      assert %{
               code: code,
               is_paid?: true,
               inserted_at: inserted_at,
               updated_at: updated_at
             } = Repo.get_by(Ticket, code: code)

      assert updated_at > inserted_at
    end
  end

  describe "Task 4 | GET /api/tickets/:barcode/state" do
    test "returns paid or unpaid" do
      code = "is_paid_code"

      {:ok, ticket} = Repo.insert(%Ticket{code: code, is_paid?: true})

      conn = conn(:get, "/api/tickets/#{code}/state")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert {:ok, %{"state" => "paid"}} == Jason.decode(conn.resp_body)

      ticket |> Ecto.Changeset.change(is_paid?: false) |> Repo.update!()

      conn = conn(:get, "/api/tickets/#{code}/state")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert {:ok, %{"state" => "unpaid"}} == Jason.decode(conn.resp_body)
    end

    test "returns unpaid if more than 15m have passed" do
      code = "out_of_time_code"
      fifteen_minutes_ago = naive_date_time(-(60 * 15) - 1)

      {:ok, ticket} =
        %Ticket{code: code, is_paid?: true, updated_at: fifteen_minutes_ago}
        |> Repo.insert()

      conn = conn(:get, "/api/tickets/#{code}/state")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert {:ok, %{"state" => "unpaid"}} == Jason.decode(conn.resp_body)
    end
  end

  describe "Task 5 | GET /api/free-spaces" do
    test "54 - given tickets" do
      %Ticket{} |> Repo.insert()

      conn = conn(:get, "/api/free-spaces")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert {:ok, %{"spaces" => 53}} == Jason.decode(conn.resp_body)
    end

    test "tickets can't be created if there are not empty spaces" do
      Enum.map(0..54, fn _x ->
        %Ticket{} |> Repo.insert()
      end)

      conn = conn(:post, "/api/tickets")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 423
    end
  end

  defp naive_date_time(shift) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(shift, :second)
    |> NaiveDateTime.truncate(:second)
  end
end
