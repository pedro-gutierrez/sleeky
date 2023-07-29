defmodule Sleeky.New.MixProject do
  use Mix.Project

  def project do
    [
      app: :sleeky_new,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        maintainers: [
          "Pedro Gutiérrez"
        ],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/pedro-gutierrez/sleeky"},
        files: ~w(lib mix.exs README.md),
        description: """
        Sleeky project generator.

        Provides a `mix sleeky.new` task to bootstrap a new Elixir application
        with Sleeky dependencies.
        """
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:eex, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end
end
