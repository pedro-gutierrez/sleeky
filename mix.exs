defmodule Sleeki.MixProject do
  use Mix.Project

  def project do
    [
      app: :sleeki,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: [
        maintainers: [
          "Pedro Gutiérrez"
        ],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/pedro-gutierrez/sleeki"},
        files: ~w(lib mix.exs README.md),
        description: """
        Sleeki project generator.

        Provides a `mix sleeki.new` task to bootstrap a new Elixir application
        with Sleeki dependencies.
        """
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
      {:bandit, "~> 1.0-pre"},
      {:calendar, "~> 1.0"},
      {:ecto, "~> 3.9"},
      {:ecto_sql, "~> 3.9"},
      {:inflex, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:postgrex, ">= 0.0.0"},
      {:plug, "~> 1.14"},
      {:slugify, "~> 1.3"},
      {:solid, "~> 0.14"}
    ]
  end
end
