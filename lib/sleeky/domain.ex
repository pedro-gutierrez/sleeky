defmodule Sleeky.Domain do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Domain.Dsl,
    parsers: [
      Sleeky.Domain.Parser
    ],
    generators: [
      Sleeky.Domain.Generator.Metadata,
      Sleeky.Domain.Generator.Roles,
      Sleeky.Domain.Generator.Allow,
      Sleeky.Domain.Generator.Scope,
      Sleeky.Domain.Generator.Graph,
      Sleeky.Domain.Generator.Helpers,
      Sleeky.Domain.Generator.CreateActions,
      Sleeky.Domain.Generator.UpdateActions,
      Sleeky.Domain.Generator.ReadActions,
      Sleeky.Domain.Generator.DeleteActions,
      Sleeky.Domain.Generator.ListActions,
      Sleeky.Domain.Generator.Transaction
    ]

  defstruct [:name, :scopes, :repo, models: []]
end
