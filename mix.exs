defmodule DataFetcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_fetcher,
      description:
        "DataFetcher is a library that can ease fetch-and-cache jobs for Elixir projects.",
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
      ],
      docs: docs(),
      package: package(),
      source_url: "https://github.com/qhwa/data_fetcher"
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
      {:ex_doc, "~> 0.21", only: [:dev, :doc], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "DataFetcher"
    ]
  end

  defp package do
    [
      name: "data_fetcher",
      files: ~w[lib mix.exs],
      licenses: ["MIT"],
      links: %{
        "github" => "https://github.com/qhwa/data_fetcher"
      }
    ]
  end
end
