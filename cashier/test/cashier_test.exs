defmodule CashierTest do
  use ExUnit.Case, async: true
  doctest Cashier
  doctest Cashier.Product
  doctest Discountable

  alias Cashier.Product
  alias Cashier.Discount.OneFor
  alias Cashier.Discount.Bulk

  @valid_product_codes ["GR1", "SR1", "CR1"]

  @products %{
    green_tea: Product.new("GR1") |> elem(1),
    strawberries: Product.new("SR1") |> elem(1),
    coffe: Product.new("CR1") |> elem(1)
  }

  @default_rules %{
    "GR1" => %OneFor{type: :one},
    "SR1" => %Bulk.Fixed{from: 2, amount: 0.5},
    "CR1" => %Bulk.Percentage{from: 2, fraction: 1 / 3}
  }

  describe "checkout" do
    setup do
      {:ok, @products}
    end

    test "new" do
      assert %Cashier{items: [], pricing_rules: %{}} = Cashier.new(%{})
    end

    test "adds a new product to the checkout items list" do
      {_key, random_product} = Enum.random(@products)

      assert %{items: [random_product]} =
               %{}
               |> Cashier.new()
               |> Cashier.scan(random_product)
    end

    test "total sums all item prices in the checkout",
         %{coffe: coffe, green_tea: green_tea} do
      assert 14.34 ==
               %{}
               |> Cashier.new()
               |> Cashier.scan(coffe)
               |> Cashier.scan(green_tea)
               |> Cashier.total()
    end

    test "Basket: GR1,SR1,GR1,GR1,CF1 expects total price £22.45",
         %{coffe: coffe, strawberries: strawberries, green_tea: green_tea} do
      assert 22.45 ==
               @default_rules
               |> Cashier.new()
               |> Cashier.scan(green_tea)
               |> Cashier.scan(strawberries)
               |> Cashier.scan(green_tea)
               |> Cashier.scan(green_tea)
               |> Cashier.scan(coffe)
               |> Cashier.total()
    end

    test "Basket: GR1,GR1 expects total price £3.11", %{green_tea: green_tea} do
      assert 3.11 ==
               @default_rules
               |> Cashier.new()
               |> Cashier.scan(green_tea)
               |> Cashier.scan(green_tea)
               |> Cashier.total()
    end

    test "Basket: SR1,SR1,GR1,SR1 expects total price £16.61",
         %{strawberries: strawberries, green_tea: green_tea} do
      assert 16.61 ==
               @default_rules
               |> Cashier.new()
               |> Cashier.scan(strawberries)
               |> Cashier.scan(strawberries)
               |> Cashier.scan(green_tea)
               |> Cashier.scan(strawberries)
               |> Cashier.total()
    end

    test "Basket: GR1,CF1,SR1,CF1,CF1 expects total price £30.57",
         %{coffe: coffe, strawberries: strawberries, green_tea: green_tea} do
      assert 30.57 ==
               @default_rules
               |> Cashier.new()
               |> Cashier.scan(green_tea)
               |> Cashier.scan(coffe)
               |> Cashier.scan(strawberries)
               |> Cashier.scan(coffe)
               |> Cashier.scan(coffe)
               |> Cashier.total()
    end
  end

  describe "product" do
    test "new has code, name and price" do
      assert {:ok, %Product{code: _, name: _, price: _}} = Product.new("GR1")
    end

    test "valid products" do
      Enum.each(@valid_product_codes, fn code ->
        assert {:ok, %Product{}} = Product.new(code)
      end)
    end
  end
end
