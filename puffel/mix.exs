defmodule Puffel.MixProject do
  use Mix.Project

  def project do
    [
      app: :puffel,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: [
        puffel: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ],
      dialyzer: [
        plt_add_deps: [:apps_direct],
        plt_add_apps: [:mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :goth, :prometheus_ex, :prometheus_plugs],
      mod: {Puffel.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:google_api_pub_sub, "~> 0.0.1"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:goth, "~> 0.7.0"},
      {:ecto_sql, "~> 3.0"},
      {:prometheus_ex, "~> 3.0"},
      {:prometheus_plugs, "~> 1.1"},
      {:postgrex, ">= 0.0.0"}
    ]
  end

  defp aliases do
    [
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
