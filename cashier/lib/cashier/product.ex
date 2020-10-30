defmodule Cashier.Product do
  @moduledoc """
  Provides a set of functions to work with products.

  The product list is defined within this module. All products have the same
  attributes, if they had other particularities, they should have been shaped
  into their own data structure.

  A product needs to have a code, a name and a price. The product instantiation
  requires that definition already exists in `@products` map.

  ## Products

      @products %{
        "GR1" => %{name: "Green Tea", price: 3.11},
        "SR1" => %{name: "Strawberries", price: 5.0},
        "CR1" => %{name: "Coffee", price: 11.23}
      }
  """

  alias __MODULE__

  defstruct code: "", name: "", price: 0

  @products %{
    "GR1" => %{name: "Green Tea", price: 3.11},
    "SR1" => %{name: "Strawberries", price: 5.0},
    "CR1" => %{name: "Coffee", price: 11.23}
  }

  @typedoc """
  Product attributes.

    * `:code`  - A unique product identifier.
    * `:name`  - Descriptive product name.
    * `:price` - Float of the product value.
  """

  @type code :: String.t()

  @type t :: %__MODULE__{code: code, name: String.t(), price: float()}

  @doc """
  Instantiates a new product. Expects a `code`.

  Returns `{:ok, %Product{}}` or `{:error, :not_found}`.

  ## Examples

        iex> {:ok, _product} = Cashier.Product.new("SR1")
        {:ok, %Cashier.Product{code: "SR1", name: "Strawberries", price: 5.0}}

        iex> Cashier.Product.new(:not_defined)
        {:error, :not_found}
  """
  @spec new(code) :: {:ok, %Product{}} | {:error, :not_found}
  def new(code) do
    @products
    |> Map.get(code)
    |> case do
      %{} = product ->
        product =
          Product
          |> struct(product)
          |> Map.put(:code, code)

        {:ok, product}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Gets the `Product` price.

  ## Examples

        iex> Cashier.Product.price("SR1")
        5.0

        iex> Cashier.Product.price("SR1")
        5.0
  """
  @spec price(code) :: float | nil
  def price(code), do: Map.get(@products, code)[:price]
end
