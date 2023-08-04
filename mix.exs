defmodule Sleeky.MixProject do
  use Mix.Project

  def project do
    [
      app: :sleeky,
      version: "0.0.1",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(),
      start_permanent: Mix.env() == :prod,
      package: [
        maintainers: [
          "Pedro Gutiérrez"
        ],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/pedro-gutierrez/sleeky"},
        files: ~w(lib mix.exs .formatter.exs LICENSE.md README.md),
        description: "Minimalist Elixir application framework"
      ],
      deps: deps()
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
      {:bandit, "~> 0.7"},
      {:calendar, "~> 1.0"},
      {:ecto, "~> 3.9"},
      {:ecto_sql, "~> 3.9"},
      {:ex_doc, ">= 0.0.0"},
      {:floki, "~> 0.34.0"},
      {:inflex, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:postgrex, ">= 0.0.0"},
      {:plug, "~> 1.14"},
      {:slugify, "~> 1.3"},
      {:solid, "~> 0.14"}
    ]
  end

  defp elixirc_paths do
    case Mix.env() do
      :test -> ["lib", "test/support"]
      _env -> ["lib"]
    end
  end
end
