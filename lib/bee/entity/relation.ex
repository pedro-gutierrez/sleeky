defmodule Bee.Entity.Relation do
  alias Bee.Entity
  alias Bee.Entity.ForeignKey

  defstruct [
    :name,
    :kind,
    :entity,
    :target,
    :column,
    :foreign_key,
    required: true,
    immutable: false,
    computed: false
  ]

  def new(fields) do
    __MODULE__
    |> struct(fields)
    |> with_simple_entity()
    |> with_target()
    |> with_column()
  end

  def inverse(%{kind: :child} = rel) do
    new(name: rel.entity.name, kind: :parent, entity: rel.entity)
  end

  defp with_simple_entity(rel) do
    entity =
      rel.entity
      |> Map.put(:attributes, [])
      |> Map.put(:parents, [])
      |> Map.put(:children, [])

    %{rel | entity: entity}
  end

  defp with_target(rel) do
    name = target_name(rel)
    target = Module.concat(rel.entity.context, name)

    %{rel | target: Entity.new(target)}
  end

  defp target_name(%{kind: :parent} = rel) do
    rel.name |> to_string() |> Inflex.camelize()
  end

  defp target_name(%{kind: :child} = rel) do
    rel.name |> to_string() |> Inflex.camelize() |> Inflex.singularize()
  end

  defp with_column(%{kind: :parent} = rel) do
    column = String.to_atom("#{rel.name}_id")
    fk = ForeignKey.new(rel)

    %{rel | foreign_key: fk, column: column}
  end

  defp with_column(rel), do: rel
end
