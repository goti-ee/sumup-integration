defmodule SumupIntegration.MixProject do
  use Mix.Project

  def project do
    [
      app: :sumup_integration,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      releases: [
        sumup_integration: [
          applications: [
            opentelemetry: :temporary
          ]
        ]
      ],
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {SumupIntegration.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.4.0"},
      {:flow, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:oban, "~> 2.17"},
      {:testcontainers, "~> 1.8"},
      {:tzdata, "~> 1.1"},
      {:opentelemetry, "~> 1.3"},
      {:opentelemetry_api, "~> 1.2"},
      {:opentelemetry_exporter, "~> 1.6"},
      {:opentelemetry_ecto, "~> 1.2"},
      {:opentelemetry_oban, "~> 1.1"},
      {:plug, "~> 1.0", only: :test},
      {:faker, "~> 0.18", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
