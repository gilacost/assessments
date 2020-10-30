defmodule TapiWeb.TransactionTest do
  use ExUnit.Case, async: true

  alias Tapi.Models.{Transaction, Account}
  alias TapiWeb.Http

  @transaction %Transaction{
    account_id: "test_acc_1JBMeXJR",
    amount: -1486,
    date: ~D[2020-09-17],
    description: "Foot Locker",
    id: "test_txt_DHSlhFVZ",
    links: %{
      account: Http.route_for(:account, "test_acc_1JBMeXJR"),
      self: Http.route_for(:transactions, ["test_acc_1JBMeXJR", "test_txt_DHSlhFVZ"])
    },
    running_balance: -234_986,
    type: "card_payment"
  }

  test "an account has transactions of the last 90 days and they stay the same" do
    {_account, transactions} = transactions_at_date([{1810, 1811, 1812}], ~D[2020-09-17])
    assert List.first(transactions) == @transaction

    {_account, transactions} = transactions_at_date([{1810, 1811, 1812}], ~D[2020-09-18])
    assert Enum.at(transactions, 5) == @transaction
  end

  test "running balance is the sum of all transactions" do
    {account, transactions} = transactions_at_date([{1810, 1811, 1812}], ~D[2020-09-11])
    first_tx = List.last(transactions)
    total_tx_amount = Enum.reduce(transactions, 0, &(&1.amount + &2))

    assert account.balances.available ==
             first_tx.running_balance + total_tx_amount - first_tx.amount
  end

  describe "transaction json encoded" do
    setup do
      {_account, transactions} = transactions_at_date([{1810, 1811, 1812}], ~D[2020-09-11])
      [transaction: transactions |> List.first() |> Jason.encode!() |> Jason.decode!()]
    end

    test "account_number, balances and routing_numbers are strings", %{transaction: txt} do
      assert is_binary(txt["running_balance"])
      assert is_binary(txt["date"])
      assert is_binary(txt["amount"])
    end

    test "running balance is an string that has two decimals at maximum", %{transaction: txt} do
      [_integer, decimals] = String.split(txt["running_balance"], ".")

      assert decimals
             |> String.codepoints()
             |> length() <= 2
    end
  end

  defp transactions_at_date(seeds, date) do
    Application.put_env(:tapi, :today, fn -> date end)

    transactions =
      seeds
      |> Account.build_for_seed(false)
      |> List.first()
      |> Transaction.build_for_account()

    {Account.build_for_seed(seeds, true) |> List.first(), transactions}
  end
end
