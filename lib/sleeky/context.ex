defmodule Sleeky.Context do
  @moduledoc """
  A schema acts as a container for models.

  ```elixir
  defmodule MyApp.Context do
    use Sleeky.Context

    context do
      model MyApp.Context.Blog
      model Myapp.Context.Post
    end
  end
  ```
  """
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Context.Dsl,
    parsers: [
      Sleeky.Context.Parser
    ],
    generators: [
      Sleeky.Context.Generator.Metadata,
      Sleeky.Context.Generator.Authorization,
      # Sleeky.Context.Generator.Compare,
      Sleeky.Context.Generator.Paths
      # Sleeky.Context.Generator.Evaluate
      # Sleeky.Context.Generator.Filter,
    ]

  defstruct [:name, :authorization, models: []]
end
