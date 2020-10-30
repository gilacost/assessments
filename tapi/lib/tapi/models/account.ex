defmodule Tapi.Models.Account do
  @moduledoc """
  Account defines the `struct` that has the properties of
  the data returned by `/accounts` and `/accounts/:account_id`.

  It also has builds the account for a specific seed while
  ensuring that only the maximum number of accounts will
  be built.

  **RUNNING BALANCE**: The running balance generated on
  account generation is used as starting balance to build
  the transactions. Then, a transaction amount per day is
  generated and the current balance will be the result of
  the sum of this amounts.

  The `:name` references the owner of the account and is one
  of the names listed in the `@names` attribute below.

  The `:seed` key of the `struct` is stored when the account
  is built for later use, but it is not sent to the user.
  This is due to implementation definition at the end of
  this module file where only the expected parameters are
  formated and json encoded.

  ## Examples

      iex> import Tapi.Models.Account
      iex> build_for_seed({1,1,1}, true) |> Jason.encode! |> Jason.decode!() |> Map.get("seed")
      nil

  """

  defstruct [
    :account_number,
    :tx_amount_per_day,
    :balances,
    :currency_code,
    :enrollment_id,
    :id,
    :institution,
    :links,
    :name,
    :routing_numbers,
    :seed
  ]

  @init_date ~D[2020-05-20]

  @type t :: %__MODULE__{
          account_number: integer,
          tx_amount_per_day: [integer],
          balances: %{available: integer, ledger: integer},
          currency_code: Tapi.Data.Currency.t(),
          enrollment_id: Tapi.Random.id(),
          id: Tapi.Random.id(),
          institution: Tapi.Data.Institution.t(),
          links: %{self: String.t(), transactions: String.t()},
          name: String.t(),
          routing_numbers: %{ach: integer, wire: integer},
          seed: Tapi.Random.seed()
        }

  @names [
    "Jimmy Carter",
    "Ronald Reagan",
    "George H. W. Bush",
    "Bill Clinton",
    "George W. Bush",
    "Barack Obama",
    "Donald Trump"
  ]

  @max_per_user 4

  alias __MODULE__
  alias Tapi.Random
  alias TapiWeb.Http

  @doc """
  Generates an account or a list of accounts given a seed or
  a list of seeds.

  Expects:

    * `:seed` or `[seed]` - the seed/s used to generate the
    account data. Should be of type `Random.seed()`.
    * `:with_current_balance?` - a boolean that will
    determine if the account should be returned with the
    current balance or the starting balance.

  The account(s) will be always the same for the same seed(s).

  ## Examples

      iex> Tapi.Models.Account.build_for_seed({1,1,1}, true) |> Map.delete(:tx_amount_per_day)
      %{
        __struct__: Tapi.Models.Account,
        account_number: 8913460602,
        balances: %{available: -182507, ledger: -182507},
        currency_code: "BAM",
        enrollment_id: "test_acc_5FF9THk9",
        id: "test_acc_I0PQFlT1",
        institution: %{id: "Chase", name: "Chase"},
        links: %{
          self: "http://localhost:4002/accounts/test_acc_I0PQFlT1",
          transactions: "http://localhost:4002/accounts/test_acc_I0PQFlT1/transactions"
        },
        name: "George H. W. Bush",
        routing_numbers: %{ach: 116628335, wire: 533000351},
        seed: {1, 1, 1}
      }

  """

  @spec build_for_seed([Random.seed()], boolean) :: [t()]
  def build_for_seed(seeds, with_current_balance?) when is_list(seeds) do
    Enum.map(seeds, &build_for_seed(&1, with_current_balance?))
  end

  @spec build_for_seed(Random.seed(), boolean) :: t()
  def build_for_seed(seed, with_current_balance?) do
    tx_amount_per_day = tx_amount_per_day_for_account(seed)
    Random.set_seed(seed)

    institution = Random.institution()
    id = Random.id()
    starting_balance = Random.balance()

    balance =
      cond do
        with_current_balance? == true ->
          current_balance(starting_balance, tx_amount_per_day)

        true ->
          starting_balance
      end

    struct!(
      __MODULE__,
      account_number: Random.account_number(),
      tx_amount_per_day: tx_amount_per_day,
      balances: %{
        available: balance,
        ledger: balance
      },
      currency_code: Random.currency(),
      enrollment_id: Random.id(),
      id: id,
      institution: %{
        id: institution,
        name: institution
      },
      links: %{
        self: Http.route_for(:account, id),
        transactions: Http.route_for(:transactions, id)
      },
      name: Enum.random(@names),
      routing_numbers: %{
        ach: Random.routing_number(),
        wire: Random.routing_number()
      },
      seed: seed
    )
  end

  @doc """
  Returns the maximum number of accounts a user can have.
  """
  @spec max_per_user() :: integer
  def max_per_user(), do: @max_per_user

  @type tx_amount_per_day :: [{:calendar.date(), integer}]

  @spec tx_amount_per_day_for_account(Random.seed()) :: tx_amount_per_day()
  defp tx_amount_per_day_for_account({s1, s2, s3}) do
    today = Application.get_env(:tapi, :today).()
    days_to_build = Date.diff(today, @init_date)

    Enum.map(days_to_build..0, fn day ->
      erl_date =
        {year, month, day} =
        Application.get_env(:tapi, :today).()
        |> Date.add(-day)
        |> Date.to_erl()

      Random.set_seed({s1 + year, s2 + month, s3 + day})
      {erl_date, Random.daily_tx_amount()}
    end)
  end

  @spec current_balance(integer, tx_amount_per_day()) :: integer
  defp current_balance(starting_balance, tx_amount_per_day) do
    tx_total =
      tx_amount_per_day
      |> Enum.into(%{})
      |> Map.values()
      |> Enum.sum()

    starting_balance - tx_total
  end

  defimpl Jason.Encoder, for: Account do
    def encode(%Account{} = account, _opts) do
      %{
        account_number: to_string(account.account_number),
        balances: %{
          available: to_string(account.balances.available / 100),
          ledger: to_string(account.balances.ledger / 100)
        },
        currency_code: account.currency_code,
        enrollment_id: account.enrollment_id,
        id: account.id,
        institution: %{
          id: Recase.to_camel(account.institution.id),
          name: account.institution.name
        },
        links: account.links,
        name: account.name,
        routing_numbers: %{
          ach: to_string(account.routing_numbers.ach),
          wire: to_string(account.routing_numbers.wire)
        }
      }
      |> Jason.encode!()
    end
  end
end
