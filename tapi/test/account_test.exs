defmodule TapiWeb.AccountTest do
  use ExUnit.Case, async: true
  alias Tapi.Models.Account
  alias TapiWeb.Http

  @account %Account{
    account_number: 8_913_460_602,
    balances: %{available: -182_507, ledger: -182_507},
    currency_code: "BAM",
    enrollment_id: "test_acc_5FF9THk9",
    id: "test_acc_I0PQFlT1",
    institution: %{id: "Chase", name: "Chase"},
    links: %{
      self: Http.route_for(:account, "test_acc_I0PQFlT1"),
      transactions: Http.route_for(:transactions, "test_acc_I0PQFlT1")
    },
    name: "George H. W. Bush",
    routing_numbers: %{ach: 116_628_335, wire: 533_000_351},
    seed: {1, 1, 1},
    tx_amount_per_day: [
      {{2020, 5, 20}, 3574},
      {{2020, 5, 21}, 11391},
      {{2020, 5, 22}, 4508},
      {{2020, 5, 23}, 7467},
      {{2020, 5, 24}, 9226},
      {{2020, 5, 25}, 8465},
      {{2020, 5, 26}, 3102},
      {{2020, 5, 27}, 5466},
      {{2020, 5, 28}, 7434},
      {{2020, 5, 29}, 7634},
      {{2020, 5, 30}, 9439},
      {{2020, 5, 31}, 10024},
      {{2020, 6, 1}, 7386},
      {{2020, 6, 2}, 3189},
      {{2020, 6, 3}, 8966},
      {{2020, 6, 4}, 3592},
      {{2020, 6, 5}, 8533},
      {{2020, 6, 6}, 6743},
      {{2020, 6, 7}, 10716},
      {{2020, 6, 8}, 3226},
      {{2020, 6, 9}, 10713},
      {{2020, 6, 10}, 11286},
      {{2020, 6, 11}, 10662},
      {{2020, 6, 12}, 12281},
      {{2020, 6, 13}, 4715},
      {{2020, 6, 14}, 7764},
      {{2020, 6, 15}, 11713},
      {{2020, 6, 16}, 7657},
      {{2020, 6, 17}, 11554},
      {{2020, 6, 18}, 4648},
      {{2020, 6, 19}, 11036},
      {{2020, 6, 20}, 3050},
      {{2020, 6, 21}, 4405},
      {{2020, 6, 22}, 11596},
      {{2020, 6, 23}, 3656},
      {{2020, 6, 24}, 3770},
      {{2020, 6, 25}, 8829},
      {{2020, 6, 26}, 8132},
      {{2020, 6, 27}, 5626},
      {{2020, 6, 28}, 8073},
      {{2020, 6, 29}, 9880},
      {{2020, 6, 30}, 8846},
      {{2020, 7, 1}, 10297},
      {{2020, 7, 2}, 8647},
      {{2020, 7, 3}, 9999},
      {{2020, 7, 4}, 3527},
      {{2020, 7, 5}, 7552},
      {{2020, 7, 6}, 5932},
      {{2020, 7, 7}, 10890},
      {{2020, 7, 8}, 12297},
      {{2020, 7, 9}, 10978},
      {{2020, 7, 10}, 7065},
      {{2020, 7, 11}, 7547},
      {{2020, 7, 12}, 2819},
      {{2020, 7, 13}, 6972},
      {{2020, 7, 14}, 3125},
      {{2020, 7, 15}, 10105},
      {{2020, 7, 16}, 2886},
      {{2020, 7, 17}, 10407},
      {{2020, 7, 18}, 11008},
      {{2020, 7, 19}, 6902},
      {{2020, 7, 20}, 2853},
      {{2020, 7, 21}, 5789},
      {{2020, 7, 22}, 7964},
      {{2020, 7, 23}, 3589},
      {{2020, 7, 24}, 8330},
      {{2020, 7, 25}, 9176},
      {{2020, 7, 26}, 10231},
      {{2020, 7, 27}, 3292},
      {{2020, 7, 28}, 5568},
      {{2020, 7, 29}, 9006},
      {{2020, 7, 30}, 10699},
      {{2020, 7, 31}, 3159},
      {{2020, 8, 1}, 4651},
      {{2020, 8, 2}, 11720},
      {{2020, 8, 3}, 11507},
      {{2020, 8, 4}, 5349},
      {{2020, 8, 5}, 10846},
      {{2020, 8, 6}, 5533},
      {{2020, 8, 7}, 2935},
      {{2020, 8, 8}, 3371},
      {{2020, 8, 9}, 6223},
      {{2020, 8, 10}, 6280},
      {{2020, 8, 11}, 8908},
      {{2020, 8, 12}, 9531},
      {{2020, 8, 13}, 7353},
      {{2020, 8, 14}, 12068},
      {{2020, 8, 15}, 5915},
      {{2020, 8, 16}, 12496},
      {{2020, 8, 17}, 11117},
      {{2020, 8, 18}, 4699},
      {{2020, 8, 19}, 7707},
      {{2020, 8, 20}, 2888},
      {{2020, 8, 21}, 11969},
      {{2020, 8, 22}, 2798},
      {{2020, 8, 23}, 12423},
      {{2020, 8, 24}, 6490},
      {{2020, 8, 25}, 10223},
      {{2020, 8, 26}, 9951},
      {{2020, 8, 27}, 5886},
      {{2020, 8, 28}, 3401},
      {{2020, 8, 29}, 6314},
      {{2020, 8, 30}, 3760},
      {{2020, 8, 31}, 2942},
      {{2020, 9, 1}, 8364},
      {{2020, 9, 2}, 5485},
      {{2020, 9, 3}, 3928},
      {{2020, 9, 4}, 5645},
      {{2020, 9, 5}, 8539},
      {{2020, 9, 6}, 4196},
      {{2020, 9, 7}, 4321},
      {{2020, 9, 8}, 5815},
      {{2020, 9, 9}, 10630},
      {{2020, 9, 10}, 7804},
      {{2020, 9, 11}, 11394}
    ]
  }

  setup_all do
    Application.put_env(:tapi, :today, fn -> ~D[2020-09-11] end)
    :ok
  end

  test "account is always the same for a certain seed" do
    assert @account == Account.build_for_seed({1, 1, 1}, true)
  end

  test "accounts can be built from a list of seeds" do
    assert [@account, _] = Account.build_for_seed([{1, 1, 1}, {2, 2, 2}], true)
  end

  describe "account json encoded" do
    setup do
      [account: Account.build_for_seed({1, 1, 1}, true) |> Jason.encode!() |> Jason.decode!()]
    end

    test "account_number, balances and routing_numbers are strings", %{account: account} do
      assert is_binary(account["account_number"])
      assert is_binary(account["balances"]["available"])
      assert is_binary(account["balances"]["ledger"])
      assert is_binary(account["routing_numbers"]["ach"])
      assert is_binary(account["routing_numbers"]["wire"])
    end

    test "institution id is camelized", %{account: account} do
      assert account["institution"]["id"] == "chase"
    end

    test "available balance is an string that has two decimals at maximum", %{account: account} do
      [_integer, decimals] = String.split(account["balances"]["available"], ".")

      assert decimals
             |> String.codepoints()
             |> length() <= 2
    end

    test "does not contain seed", %{account: account} do
      assert Map.get(account, "seed") == nil
    end
  end
end
