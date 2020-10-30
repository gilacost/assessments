defmodule Tapi.Models.Transaction do
  @moduledoc """
  Transaction defines the `struct` that has the properties of
  the data returned by `/accounts/:account_id/transactions`.

  It builds a list of transactions from the last 90 days. To
  do so, it uses the seed in the account. The seed needs to
  be of type `Tapi.Random.seed()`.

  The main function expects an account that will contain a
  list of days with a transaction amount that will be used
  to generate a list of transactions. This list was
  generated from a fixed date in the past. The transactions
  of the last 90 days are then filtered and returned. By
  having a fixed starting date, we ensure that all
  transactions are the same even after a day passes or the
  application is stopped and started again.

  Normally the today function used in this module returns
  the current date. In order to be able to test this, a mock
  has been created which uses a fixed date or allows you to
  specify a date of your choice, find the test
  [here](https://github.com/gilacost/tapi/blob/main/test/transaction_test.exs#L21).

  """

  defstruct [
    :account_id,
    :running_balance,
    :links,
    :id,
    :description,
    :date,
    :amount,
    type: "card_payment"
  ]

  @type t :: %__MODULE__{
          account_id: Tapi.Random.id(),
          running_balance: integer,
          links: %{self: String.t(), transactions: String.t()},
          id: Tapi.Random.id(),
          description: Tapi.Data.Merchant.t(),
          date: Date.t(),
          amount: integer,
          type: String.t()
        }

  alias __MODULE__
  alias Tapi.{Random, Models.Account}
  alias TapiWeb.Http

  @doc """
  Generates a list of transactions for the last 90 days
  given an account or a list of accounts. There might be
  more than one transaction per day.

  The transactions will be always the same for the same
  account.

  The sum of all transactions is the current running balance
  of the account.

  Uses map reduce to iterate over the days list and
  accumulates the balance.

  If more than one transaction per day are built, the amount
  of these transactions will be embedded into the daily
  transaction amount generated for that day in the account.

  ## Examples

      iex> import Tapi.Models.{Account, Transaction}
      iex> account = build_for_seed({1,1,1}, false)
      iex> build_for_account(account) |> List.first
      %Tapi.Models.Transaction{
        account_id: "test_acc_I0PQFlT1",
        amount: -5708,
        date: ~D[2020-09-11],
        description: "Apple",
        id: "test_txt_udsNd1cE",
        links: %{
          account: "http://localhost:4002/accounts/test_acc_I0PQFlT1",
          self: "http://localhost:4002/accounts/test_acc_I0PQFlT1/transactions/test_txt_udsNd1cE"
        },
        running_balance: -182507,
        type: "card_payment"
      }

  """
  @spec build_for_account(Account.t()) :: [t()]
  def build_for_account(%Account{
        tx_amount_per_day: tx_amount_per_day,
        id: account_id,
        seed: seed,
        balances: %{available: balance}
      }) do
    build_tx_fun = Application.get_env(:tapi, :do_build_for_account)

    {transaction_list, _current_balance} =
      Enum.map_reduce(tx_amount_per_day, balance, fn {day, tx_amount}, balance ->
        build_tx_fun.(day, seed, account_id, tx_amount, balance)
      end)

    ninety_days_ago = Date.utc_today() |> Date.add(-89)

    transaction_list
    |> List.flatten()
    |> Enum.reverse()
    |> Enum.reject(&(Date.compare(&1.date, ninety_days_ago) == :lt))
  end

  @spec do_build_for_account_one_per_day(
          :calendar.date(),
          Random.seed(),
          Random.id(),
          integer,
          integer
        ) :: {t(), integer}
  def do_build_for_account_one_per_day(
        {year, month, day} = date,
        {s1, s2, s3},
        account_id,
        tx_amount,
        balance
      ) do
    Random.set_seed({s1 + year, s2 + month, s3 + day})
    transaction = build_transaction(balance, tx_amount, account_id, date)
    {transaction, balance - tx_amount}
  end

  @spec do_build_for_account(
          :calendar.date(),
          Random.seed(),
          Random.id(),
          integer,
          integer
        ) :: {[t()], integer}
  def do_build_for_account(
        {year, month, day} = date,
        {s1, s2, s3},
        account_id,
        tx_amount,
        balance
      ) do
    Random.set_seed({s1 + year, s2 + month, s3 + day})

    num_of_transactions = :rand.uniform(4)

    max =
      tx_amount
      |> Integer.floor_div(num_of_transactions)
      |> Integer.floor_div(100)

    {transaction_list, {balance, _tx_acc}} =
      Enum.map_reduce(0..num_of_transactions, {balance, 0}, fn txt_index, {balance, tx_acc} ->
        Random.set_seed({s1 + year + txt_index, s2 + month + txt_index, s3 + day + txt_index})

        amount =
          if txt_index == num_of_transactions do
            tx_amount - tx_acc
          else
            Random.amount(max)
          end

        transaction = build_transaction(balance, amount, account_id, date)

        {transaction, {balance - amount, tx_acc + amount}}
      end)

    {transaction_list, balance}
  end

  @spec build_transaction(integer, integer, Random.id(), :calendar.date()) :: t
  defp build_transaction(balance, amount, account_id, date) do
    id = Random.transaction_id()
    merchant = Random.merchant()

    struct!(
      __MODULE__,
      running_balance: balance - amount,
      id: id,
      links: %{
        self: Http.route_for(:transactions, [account_id, id]),
        account: Http.route_for(:account, account_id)
      },
      description: merchant,
      date: Date.from_erl!(date),
      amount: -amount,
      account_id: account_id
    )
  end

  defimpl Jason.Encoder, for: Transaction do
    def encode(%Transaction{} = transaction, _opts) do
      %{
        account_id: transaction.account_id,
        running_balance: to_string(transaction.running_balance / 100),
        links: transaction.links,
        id: transaction.id,
        description: transaction.description,
        date: to_string(transaction.date),
        amount: to_string(transaction.amount / 100),
        type: transaction.type
      }
      |> Jason.encode!()
    end
  end
end
