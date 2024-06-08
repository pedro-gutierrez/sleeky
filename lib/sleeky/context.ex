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
      Sleeky.Context.Generator.Paths,
      Sleeky.Context.Generator.CreateActions,
      Sleeky.Context.Generator.UpdateActions,
      Sleeky.Context.Generator.ReadActions,
      Sleeky.Context.Generator.DeleteActions,
      Sleeky.Context.Generator.ListActions
    ]

  defstruct [:name, :authorization, :repo, models: []]
end
