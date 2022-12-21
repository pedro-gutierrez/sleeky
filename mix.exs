defmodule Bee.MixProject do
  use Mix.Project

  def project do
    [
      app: :bee,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
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
      {:bandit, ">= 0.6.3"},
      {:calendar, "~> 1.0.0"},
      {:ecto, "~> 3.9"},
      {:ecto_sql, "~> 3.9"},
      {:html_builder, "~> 0.1"},
      {:inflex, "~> 2.0.0"},
      {:jason, "~> 1.2"},
      {:postgrex, ">= 0.0.0"},
      {:plug, "~> 1.14"},
      {:slugify, "~> 1.3"}
    ]
  end
end
