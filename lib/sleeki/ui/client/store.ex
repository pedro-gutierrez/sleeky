defmodule Sleeki.UI.Client.Store do
  @moduledoc false

  @generators [
    Sleeki.UI.Client.Collection,
    Sleeki.UI.Client.Item,
    Sleeki.UI.Client.Actions
  ]

  alias ESTree.Tools.Builder, as: JS

  import Sleeki.Inspector
  import Sleeki.UI.Client.Helpers

  def ast(schema) do
    Enum.map(schema.entities, &store/1)
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
