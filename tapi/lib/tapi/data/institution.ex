defmodule Tapi.Data.Institution do
  @moduledoc ~S"""
  A data module that contains a list of institutions.

  It is called from the `Tapi.Random` module.

  ## Examples

      iex> Tapi.Data.Institution.list() |> List.first()
      "Bank of America"

  This list will be used to provide a random financial
  institution associated to a user account.

  """

  @type t :: String.t()

  use Tapi, :data

  @data ["Bank of America", "Chase", "Wells Fargo", "Citi", "Capital One"]
end
