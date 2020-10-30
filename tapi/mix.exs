defmodule Tapi.MixProject do
  use Mix.Project

  #       elixir: "~> 1.10.4",
  def project do
    [
      app: :tapi,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      elixirc_options: [warnings_as_errors: true],
      docs: [
        main: "readme",
        logo: "logo.svg",
        extras: ["README.md"],
        groups_for_modules: module_groups(),
        assets: "assets/docs"
      ],
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      mod: {Tapi.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.5.4"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:timex, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:recase, "~> 0.5"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end

  defp module_groups() do
    [
      Tapi: [
        Tapi,
        Tapi.Application,
        Tapi.Random
      ],
      "Tapi data": [
        Tapi.Data.Currency,
        Tapi.Data.Institution,
        Tapi.Data.Merchant
      ],
      "Tapi models": [
        Tapi.Models.Account,
        Tapi.Models.Transaction
      ],
      "Tapi Web": [
        TapiWeb.ApiRouter,
        TapiWeb.BasicAuth,
        TapiWeb.Http,
        TapiWeb.Router,
        TapiWeb.Telemetry
      ],
      Boilerplate: [
        TapiWeb,
        TapiWeb.Endpoint,
        TapiWeb.Router.Helpers,
        TapiWeb.UserSocket
      ]
    ]
  end
end
