defmodule Bee.UI.Client.Store do
  @moduledoc false

  @generators [
    Bee.UI.Client.Collection,
    Bee.UI.Client.Item,
    Bee.UI.Client.Actions
  ]

  alias ESTree.Tools.Builder, as: JS

  import Bee.Inspector
  import Bee.UI.Client.Helpers

  def ast(schema) do
    schema.entities
    |> Enum.map(&store/1)
    |> event_listener("alpine:init")
  end

  defp store(entity) do
    name = JS.literal(entity.plural())

    content =
      @generators
      |> Enum.map(& &1.ast(entity))
      |> flatten()
      |> JS.object_expression()

    call("Alpine.store", [name, content])
  end
end
