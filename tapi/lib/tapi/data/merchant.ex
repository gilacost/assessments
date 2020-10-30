defmodule Tapi.Data.Merchant do
  @moduledoc ~S"""
  A data module that contains a list of merchants.

  It is called from the `Tapi.Random` module.

  ## Examples

      iex> Tapi.Data.Merchant.list() |> List.first()
      "Uber"

  This list will be used to provide a random description in
  the account transactions.

  """

  @type t :: String.t()

  use Tapi, :data

  @data [
    "Uber",
    "Uber Eats",
    "Lyft",
    "Five Guys",
    "In-N-Out Burger",
    "Chick-Fil-A",
    "AMC Metreon",
    "Apple",
    "Amazon",
    "Walmart",
    "Target",
    "Hotel Tonight",
    "Misson Ceviche",
    "The Creamery",
    "Caltrain",
    "Wingstop",
    "Slim Chickens",
    "CVS",
    "Duane Reade",
    "Walgreens",
    "Rooster & Rice",
    "McDonald's",
    "Burger King",
    "KFC",
    "Popeye's",
    "Shake Shack",
    "Lowe's",
    "The Home Depot",
    "Costco",
    "Kroger",
    "iTunes",
    "Spotify",
    "Best Buy",
    "TJ Maxx",
    "Aldi",
    "Dollar General",
    "Macy's",
    "H.E. Butt",
    "Dollar Tree",
    "Verizon Wireless",
    "Sprint PCS",
    "T-Mobile",
    "Kohl's",
    "Starbucks",
    "7-Eleven",
    "AT&T Wireless",
    "Rite Aid",
    "Nordstrom",
    "Ross",
    "Gap",
    "Bed, Bath & Beyond",
    "J.C. Penney",
    "Subway",
    "O'Reilly",
    "Wendy's",
    "Dunkin' Donuts",
    "Petsmart",
    "Dick's Sporting Goods",
    "Sears",
    "Staples",
    "Domino's Pizza",
    "Pizza Hut",
    "Papa John's",
    "IKEA",
    "Office Depot",
    "Foot Locker",
    "Lids",
    "GameStop",
    "Sephora",
    "MAC",
    "Panera",
    "Williams-Sonoma",
    "Saks Fifth Avenue",
    "Chipotle Mexican Grill",
    "Exxon Mobil",
    "Neiman Marcus",
    "Jack In The Box",
    "Sonic",
    "Shell"
  ]
end
