defmodule TapiWeb.BasicAuth do
  @moduledoc """
  A basic auth plug.

  This plug has the following responsibilities:

    * Parses the basic auth token from the authentication
    header.
    * Ensures that the user in the bearer contains _test as
    prefix.
    * Ensures that the password in the bearer is empty.
    * Produces a random number of seeds for the user in the
    bearer and assigns them to the connection.

  """
  import Plug.Conn
  alias Tapi.{Models.Account, Random}

  @doc false
  def init([]), do: []

  @type conn :: Plug.Conn.t()

  @doc """
  Main plug call.

  It will halt the connection and request basic auth if
  something goes wrong.

  """
  @spec call(conn, Keyword.t()) :: conn
  def call(conn, _opts) do
    with {user, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
         {:ok, user} <- ensure_test_user(user),
         :ok <- ensure_empty_password(pass),
         seed <- produce_seeds(user) do
      assign(conn, :seeds, seed)
    else
      _ ->
        conn
        |> Plug.BasicAuth.request_basic_auth()
        |> halt()
    end
  end

  @spec ensure_test_user(any) :: {:ok, String.t()} | {:error, String.t()}
  defp ensure_test_user("test_" <> rest), do: {:ok, rest}
  defp ensure_test_user(_), do: {:error, "No test_ in token header"}

  @spec ensure_empty_password(any) :: :ok | {:error, String.t()}
  defp ensure_empty_password(""), do: :ok
  defp ensure_empty_password(_), do: {:error, "Password should be empty"}

  @spec produce_seeds(String.t()) :: [Random.seed()]
  defp produce_seeds(string) do
    seed = string |> String.to_charlist() |> Enum.sum()
    Random.set_seed({seed, seed, seed})
    max = :rand.uniform(Account.max_per_user())

    Enum.map(0..max, fn index ->
      {seed + index, seed + index + 1, seed + index + 2}
    end)
  end
end
