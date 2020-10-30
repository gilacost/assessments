defmodule Cashier do
  @moduledoc """
  A set of functions for interacting with the cart.
  It can be instantiated with an empty map or receive a map containing price
  rules mapped to product codes. The price rules need to implement the `Discountable`
  protocol. For more information go to Discount.apply/2.

  ## Default cashier 🛒🏃💨

      iex> Cashier.new(%{})
      %Cashier{discount: 0, items: [], pricing_rules: %{}}

  ## Default with pricing rules

  If you specify that a certain product code has a special price rule, that
  discount will be applied on cashier modification and subtracted from the total
  when `Cashier.total/1` is called:

      iex> discount = %Cashier.Discount.OneFor{}
      %Cashier.Discount.OneFor{type: :one}
      iex> checkout = Cashier.new(%{"SR1" => discount})
      %Cashier{
        discount: 0,
        items: [],
        pricing_rules: %{"SR1" => %Cashier.Discount.OneFor{type: :one}}
      }
      iex> {:ok, product} = Cashier.Product.new("SR1")
      {:ok, %Cashier.Product{code: "SR1", name: "Strawberries", price: 5.0}}
      iex> checkout = Cashier.scan(checkout, product)
      %Cashier{
        discount: 0.0,
        items: [
          %Cashier.Product{code: "SR1", name: "Strawberries", price: 5.0}
        ],
        pricing_rules: %{"SR1" => %Cashier.Discount.OneFor{type: :one}}
      }
      iex> Cashier.scan(checkout, product)
      %Cashier{
        discount: 5.0,
        items: [
          %Cashier.Product{code: "SR1", name: "Strawberries", price: 5.0},
          %Cashier.Product{code: "SR1", name: "Strawberries", price: 5.0}
        ],
        pricing_rules: %{"SR1" => %Cashier.Discount.OneFor{type: :one}}
      }
      iex> Cashier.total(checkout)
      5.0
  """

  @type t :: %__MODULE__{items: list, pricing_rules: map}
  @type pricing_rules :: map

  alias Cashier.Product

  defstruct items: [], pricing_rules: %{}, discount: 0

  @doc """
  Instantiates a new cashier. Expects a map for pricing rules. If no rules
  are passed, a map will be defaulted instead.

  ## Examples
      iex> Cashier.new()
      %Cashier{discount: 0, items: [], pricing_rules: %{}}
  """
  @spec new(pricing_rules) :: t
  def new(pricing_rules \\ %{}), do: %Cashier{pricing_rules: pricing_rules}

  @doc """
  Adds a new item to the checkout. Every time the checkout is updated, the
  different pricing rules are computed again updating the discount value.

  ## Examples:

      iex> Cashier.new() |> Cashier.scan(Cashier.Product.new("SR1") |> elem(1))
      %Cashier{
        discount: 0,
        items: [
          %Cashier.Product{code: "SR1", name: "Strawberries", price: 5.0}
        ],
        pricing_rules: %{}
      }

  It updates the cashier struct with the new product, if there is no product
  the initial value will be [`Cashier.Product`]
  """
  @spec scan(t, Product.t()) :: t()
  def scan(checkout, %Product{} = product) do
    checkout
    |> Map.update(
      :items,
      [product],
      &[product | &1]
    )
    |> apply_discounts()
  end

  @doc """
  Returns the total price value of the items in the cart with the previous
  defined pricing rules applied.

  ## Examples:

      iex> co = Cashier.new() |> Cashier.scan(Cashier.Product.new("SR1") |> elem(1))
      %Cashier{
        discount: 0,
        items: [
          %Cashier.Product{code: "SR1", name: "Strawberries", price: 5.0}
        ],
        pricing_rules: %{}
      }
      iex> Cashier.total(co)
      5.0
  """

  @spec total(t) :: float
  def total(%Cashier{items: items, discount: discount}) do
    Enum.reduce(items, 0, &(&1.price + &2)) - discount
  end

  # Counts the number of items of a certain type in the checkout.
  defp product_count(%Cashier{items: items}, code),
    do: Enum.count(items, &(&1.code == code))

  # Computes the discount iterating over checkout item list and appliying
  # previous defined pricing rules.
  defp apply_discounts(%Cashier{pricing_rules: pricing_rules} = checkout) do
    checkout = %{checkout | discount: 0}

    Enum.reduce(pricing_rules, checkout, fn {code, discount}, checkout ->
      count = product_count(checkout, code)
      Discountable.apply(discount, [count, code, checkout])
    end)
  end
end
