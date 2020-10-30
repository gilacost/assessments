defprotocol Discountable do
  @moduledoc """
  Discountable protocol used by cashier module.

  When you invoke the apply function in the `Cashier.t()` module like
  `Discountable.apply()` the first argument is a discount type that needs to
  implement this protocol.

  For example, the expression:

      Discount.apply(%Cashier.Discount.OneFor{}, [])

  Invokes `Discountable.apply/2` to compute the discount to be applied to the
  checkout for a specific product code. `Discountable.apply/2` returns a `Cashier.t()`.
  """

  @typedoc """
  The discount struct will allow us to determine which reduction needs to be
  applied. It will contain different parameters depending on the behaviour:

    * `:type`     - it can be OneFor `:one` for now.
    * `:amount`   - the fixed amount that will be subtracted from product price.
    * `:from`     - bulk discounts, from which product count discount should
    start being applied.
  start being applied.
    * `:fraction` - the fraction that will be applied to the product price.
  """
  @type discount :: struct

  @typedoc """
  A product count a product code and the checkout instance in a list:

    * `:count`    - the number of items in the checkout of a certain product
    code.
    * `:code`     - product code that will be used to query the product price.
    * `:checkout` - the container of items, pricing rules and the value to
    discount.
  """
  @type params() :: [any]

  @spec apply(discount, params) :: Cashier.t()
  def apply(discount, params)
end

defmodule Cashier.Discount do
  @moduledoc """
  The repository of the different discounts and their implementations.

  ## Examples

        iex> %Cashier.Discount.OneFor{}
        %Cashier.Discount.OneFor{type: :one}

        iex> %Cashier.Discount.Bulk.Fixed{}
        %Cashier.Discount.Bulk.Fixed{amount: 0.5, from: 3}

        iex> %Cashier.Discount.Bulk.Percentage{}
        %Cashier.Discount.Bulk.Percentage{
          fraction: 0.3333333333333333,
          from: 3
        }
  """

  alias Cashier.Product

  defmodule OneFor do
    @moduledoc """
    Discount also called buy one get one free.

    The way this has been implemented is a bit tricky. It always divides the
    number of items by 2 and then floors the result.

    Then `2/2` is 1 and `3/2` is also 1.
    """

    @typedoc """
    Type is an atom that decides if the discount will be one for `:one`.
    """

    @type t :: %__MODULE__{type: atom}

    defstruct type: :one

    defimpl Discountable do
      def apply(_type, [count, code, checkout]) do
        discount = floor(count / 2) * Product.price(code)
        Map.update(checkout, :discount, 0, &(&1 + discount))
      end
    end
  end

  defmodule Bulk.Fixed do
    @moduledoc """
    Fixed discount applied to all products of a certain type.

    It subtracts a fixed amount from the price of a product. The condition for
    this discount to be applied will be determined by the `:from`.

    For example we have a `%Bulk.Fixed{from: 3, amount: 0.5}`. This will reduce
    the price of the product 0.5 if we have 3 or more products of that type in
    the items list.
    """

    @typedoc """
    * `:from`    - minimum number of products of the same type for the discount
    to be applied.
    * `:amount`  - fixed amount to be subtracted from the product price.
    """

    @type t :: %__MODULE__{from: atom, amount: float}

    defstruct from: 3, amount: 0.5

    defimpl Discountable do
      def apply(%{from: from, amount: amount}, [count, _code, checkout])
          when count > from do
        Map.update(checkout, :discount, 0, &(&1 + count * amount))
      end

      def apply(%{}, [_count, _code, checkout]), do: checkout
    end
  end

  defmodule Bulk.Percentage do
    @moduledoc """
    It subtracts a percentage of the product price.

    Same behaviour as in `Bulk.Fixed.t()` but in this case a fraction of the
    product price is subtracted.
    """

    @typedoc """
    * `:fraction` - fraction to be multiplied by the product price.
    """

    @type t :: %__MODULE__{from: atom, fraction: float}
    defstruct from: 3, fraction: 1 / 3

    defimpl Discountable do
      def apply(%{from: from, fraction: fraction}, [count, code, checkout])
          when count > from do
        discount = count * Product.price(code) * fraction
        Map.update(checkout, :discount, 0, &(&1 + discount))
      end

      def apply(%{}, [_count, _code, checkout]), do: checkout
    end
  end
end
