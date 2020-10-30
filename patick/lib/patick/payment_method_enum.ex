defmodule Patick.PaymentMethodEnum do
  @moduledoc ~S"""
  Payment method enum type for postgres.

  It uses the `EctoEnum.Postgres` macro from the
  `:ecto_enum` library. This macro allows to validate the
  the submitted content for the type.

  ## Examples

      iex> Patick.PaymentMethodEnum.valid_value?("asdf")
      false

      iex> Patick.PaymentMethodEnum.valid_value?("cash")
      true

  This will also allow to create and assign the type in
  postgres with `Patick.PaymentMethodEnum.create_type()` and
  `Patick.PaymentMethodEnum.type()` respectfully.

  """

  use EctoEnum.Postgres, type: :payment_method, enums: [:credit_card, :debit_card, :cash]
end
