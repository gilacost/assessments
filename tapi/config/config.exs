use Mix.Config

config :tapi, :build_accounts, &Tapi.do_build_accounts_with_transactions/1

config :tapi, :today, &Date.utc_today/0

config :tapi, :algorithm, :exs1024s

config :tapi, :do_build_for_account, &Tapi.Models.Transaction.do_build_for_account/5

# if you replace `:do_build_for_account` with this only one transaction will be built per day
# config :tapi, :do_build_for_account, &Tapi.Models.Transaction.do_build_for_account_one_per_day/5

config :tapi, :api_port, 4001

config :tapi, TapiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "oHd2Kfm/4JR/WehuIt0sr/LLpCihQ5WXIDRbEnEAdjDJRuvIe+xUMSm8HfC9+qNd",
  render_errors: [view: TapiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Tapi.PubSub,
  live_view: [signing_salt: "2zAnbtnC"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
