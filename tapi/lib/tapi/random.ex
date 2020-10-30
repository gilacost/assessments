defmodule Tapi.Random do
  @moduledoc """
  Random is responsible for setting the seed that will
  ensure the same data is generated.

  It also has functions that generate the values of the
  attributes for the different models.

  ## Examples

      iex> Tapi.Random.balance == 673293
      false
      iex> Tapi.Random.set_seed(1)
      iex> Tapi.Random.balance == 673293
      true

  """
  alias Tapi.Data.{Currency, Institution, Merchant}

  @type seed :: integer | {integer, integer, integer}

  @doc """
  Sets the seed. It uses the `:exs1024s` algorithm because
  it is the one with more entropy. For more information
  about the available algorithms check the
  [docs](http://erlang.org/doc/man/rand.html).

  """
  @spec set_seed(seed) :: :rand.state()

  def set_seed(seed) do
    algorithm = Application.get_env(:tapi, :algorithm)
    :rand.seed(algorithm, seed)
  end

  @doc """
  Generates a string of the passed `length`, to do so,
  it reads from `priv/random_bytes_encoded`. This file has
  been generated with `:crypto.strong_rand_bytes(1000) |> Base.url_encode64()`


  This has been done to emulate the ids of the real teller
  test api and avoid calling `:crypto` every time.

  """
  @spec string(integer) :: String.t()
  def string(length) do
    "priv/random_bytes_encoded"
    |> File.read!()
    |> Base.url_encode64()
    |> String.graphemes()
    |> Enum.take_random(length)
    |> Enum.join()
  end

  @doc """
  Generates a total transaction amount for a day. This will
  be used to as amount among all the transactions of that
  day.

  """
  @spec daily_tx_amount() :: integer
  def daily_tx_amount() do
    integer = Enum.random(25..125)
    decimal = :rand.uniform(99)
    integer * 100 + decimal
  end

  @doc """
  Generates an account balance as an integer which
  represents a decimal.

  Later it will be encoded with the proper format.

  ## Examples

     150002 is the same as "1500,02"

  """
  @spec balance() :: integer
  def balance() do
    integer = Enum.random(5500..7500)
    decimal = :rand.uniform(99)
    integer * 100 + decimal
  end

  @doc """
  Generates a transaction amount. Works in the same way as
  `balance()`.

  """

  @spec amount(integer) :: integer
  def amount(max \\ 35) do
    integer = Enum.random(1..max)
    decimal = :rand.uniform(99)
    integer * 100 + decimal
  end

  @type id :: String.t()

  @doc """
  Generates an account id. This will be used for account
  and enrollment ids.

  ## Examples

      iex> Tapi.Random.set_seed(1)
      iex> Tapi.Random.id()
      "test_acc_b2JTRZii"

  """
  @spec id() :: id()
  def id(), do: id_for("acc")

  @doc """
  Generates a transaction id. It is the same as `id` but
  instead of __acc__ it contains __txt__.

  ## Examples

      iex> Tapi.Random.set_seed(1)
      iex> Tapi.Random.transaction_id()
      "test_txt_b2JTRZii"

  """
  @spec transaction_id() :: String.t()
  def transaction_id(), do: id_for("txt")

  @doc """
  Generates an account number.

  ## Examples

      iex> Tapi.Random.set_seed(1)
      iex> Tapi.Random.account_number()
      8826376989

  """
  @spec account_number() :: String.t()
  def account_number(), do: Enum.random(1_000_000_000..9_999_999_999)

  @doc """
  Generates a routing number.

  ## Examples

      iex> Tapi.Random.set_seed(1)
      iex> Tapi.Random.routing_number()
      726376989

  """
  @spec routing_number :: String.t()
  def routing_number(), do: Enum.random(100_000_000..999_999_999)

  @doc """
  Returns a random institution from the `Tapi.Data.Institution`
  module.
  """
  @spec institution() :: String.t()
  def institution(), do: Enum.random(Institution.list())

  @doc """
  Returns a random currency from the `Tapi.Data.Currency`
  module.
  """
  @spec currency() :: String.t()
  def currency(), do: Enum.random(Currency.list())

  @doc """
  Returns a random merchant from the `Tapi.Data.Merchant`
  module.
  """
  @spec merchant() :: String.t()
  def merchant(), do: Enum.random(Merchant.list())

  @spec id_for(String.t()) :: String.t()
  defp id_for(type), do: "test_#{type}_#{string(8)}"
end
