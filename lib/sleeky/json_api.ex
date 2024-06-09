defmodule Sleeky.JsonApi do
  @moduledoc """
  Builds a json api for your domain
  """
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.JsonApi.Dsl,
    parsers: [
      Sleeky.JsonApi.Parser
    ],
    generators: [
      Sleeky.JsonApi.Generator.IncludeDecoders,
      Sleeky.JsonApi.Generator.QueryDecoders,
      Sleeky.JsonApi.Generator.SortDecoders,
      Sleeky.JsonApi.Generator.RelationDecoders,
      Sleeky.JsonApi.Generator.CreateDecoders,
      Sleeky.JsonApi.Generator.UpdateDecoders,
      Sleeky.JsonApi.Generator.ReadDecoders,
      Sleeky.JsonApi.Generator.ListDecoders,
      Sleeky.JsonApi.Generator.ListByParentDecoders,
      Sleeky.JsonApi.Generator.DeleteDecoders,
      Sleeky.JsonApi.Generator.CreateHandlers,
      Sleeky.JsonApi.Generator.UpdateHandlers,
      Sleeky.JsonApi.Generator.ReadHandlers,
      Sleeky.JsonApi.Generator.ListHandlers,
      Sleeky.JsonApi.Generator.ListByParentHandlers,
      Sleeky.JsonApi.Generator.DeleteHandlers,
      Sleeky.JsonApi.Generator.Router
    ]

  defstruct [:contexts, :plugs]
end
