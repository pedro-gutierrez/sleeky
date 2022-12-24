defmodule Bee.UI.Client.Item do
  @moduledoc false

  import Bee.Inspector
  import Bee.UI.Client.Helpers

  alias Bee.Entity.Attribute
  alias ESTree.Tools.Builder, as: JS

  def ast(entity) do
    defaults =
      flatten([
        attributes(entity),
        parents(entity)
      ])

    JS.property(
      item(),
      JS.object_expression(defaults)
    )
  end

  def attributes(entity) do
    for %Attribute{
          immutable: false,
          virtual: false,
          computed: false,
          timestamp: false
        } = attr <- entity.attributes do
      JS.property(
        JS.identifier(attr.name),
        default_value(attr.kind)
      )
    end
  end

  def parents(entity) do
    for parent <- entity.parents() do
      JS.property(
        JS.identifier(parent.name),
        null()
      )
    end
  end

  def default_value(:string), do: empty()
  def default_value(:text), do: empty()
  def default_value(:enum), do: empty()
  def default_value(:id), do: null()
  def default_value(:boolean), do: falsy()
end
