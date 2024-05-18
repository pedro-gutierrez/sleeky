defmodule Sleeky.Context do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Context.Dsl,
    parsers: [
      Sleeky.Context.Parser
    ],
    generators: [
      Sleeky.Context.Generator.Metadata,
      Sleeky.Context.Generator.Roles,
      Sleeky.Context.Generator.Allow,
      Sleeky.Context.Generator.Scope,
      Sleeky.Context.Generator.Paths
    ]

  defstruct [:name, :authorization, :repo, models: []]
end
