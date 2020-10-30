defmodule TapiDocsTest do
  use ExUnit.Case, async: true
  doctest Tapi.Data.Currency
  doctest Tapi.Data.Merchant
  doctest Tapi.Data.Institution

  doctest Tapi.Models.Account
  doctest Tapi.Models.Transaction
  doctest Tapi.Random

  doctest TapiWeb.Http
end
