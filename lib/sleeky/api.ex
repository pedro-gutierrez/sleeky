defmodule Sleeky.Api do
  @moduledoc """
  Builds a json api for your feature
  """
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Api.Dsl,
    parsers: [
      Sleeky.Api.Parser
    ],
    generators: [
      # Sleeky.Api.Generator.IncludeDecoders,
      # Sleeky.Api.Generator.QueryDecoders,
      # Sleeky.Api.Generator.SortDecoders,
      # Sleeky.Api.Generator.RelationDecoders,
      # Sleeky.Api.Generator.CreateDecoders,
      # Sleeky.Api.Generator.UpdateDecoders,
      # Sleeky.Api.Generator.ReadDecoders,
      # Sleeky.Api.Generator.ListDecoders,
      # Sleeky.Api.Generator.ListByParentDecoders,
      # Sleeky.Api.Generator.DeleteDecoders,
      # Sleeky.Api.Generator.CreateHandlers,
      # Sleeky.Api.Generator.UpdateHandlers,
      # Sleeky.Api.Generator.ReadHandlers,
      # Sleeky.Api.Generator.ListHandlers,
      # Sleeky.Api.Generator.ListByParentHandlers,
      # Sleeky.Api.Generator.DeleteHandlers,
      Sleeky.Api.Generator.Router
    ]

  defstruct [:features, :plugs]
end
