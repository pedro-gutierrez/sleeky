defmodule Sleeky.MixProject do
  use Mix.Project

  @version "0.0.3"

  def project do
    [
      app: :sleeky,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      package: [
        maintainers: [
          "Pedro Gutiérrez"
        ],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/pedro-gutierrez/sleeky"},
        files: ~w(lib mix.exs .formatter.exs LICENSE.md README.md),
        description: "Minimalist Elixir application framework"
      ],
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :file_system]
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
      {:file_system, "~> 0.2"},
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

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "overview",
      extra_section: "GUIDES",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      formatters: ["html", "epub"]
    ]
  end

  defp extras do
    [
      "guides/introduction/overview.md",
      "guides/introduction/installation.md"
    ]
  end

  defp groups_for_extras do
    [
      Introduction: ~r/guides\/introduction\/.?/
    ]
  end
end
