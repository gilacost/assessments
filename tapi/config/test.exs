use Mix.Config

config :tapi, :build_accounts, fn _seeds ->
  [
    %{
      id: "test_acc_sGlFU3ZT",
      transactions: []
    }
  ]
end

config :tapi, :today, fn -> ~D[2020-09-11] end

config :tapi, :api_port, 4002

config :logger, level: :warn
