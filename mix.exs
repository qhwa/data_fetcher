defmodule DataFetcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_fetcher,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_local_path: "priv/plts",
        plt_file: "priv/plts/dialyzer.plt",
        plt_add_apps: [:ex_unit]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
