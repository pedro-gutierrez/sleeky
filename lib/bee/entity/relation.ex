defmodule Bee.Entity.Relation do
  alias Bee.Entity
  alias Bee.Entity.ForeignKey
  alias Bee.Entity.Summary

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
    |> with_target()
    |> with_summary_entity()
    |> with_summary_target()
    |> with_column()
    |> with_foreign_key()
  end

  def inverse(%{kind: :child} = rel) do
    new(name: rel.entity.name, kind: :parent, target: rel.entity, entity: rel.target)
  end

  defp with_summary_entity(rel) do
    %{rel | entity: Summary.new(rel.entity)}
  end

  defp with_summary_target(rel) do
    %{rel | target: Summary.new(rel.target)}
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

    %{rel | column: column}
  end

  defp with_column(rel), do: rel

  defp with_foreign_key(%{kind: :parent} = rel) do
    fk = ForeignKey.new(rel)

    %{rel | foreign_key: fk}
  end

  defp with_foreign_key(%{kind: :child} = rel) do
    fk =
      rel
      |> inverse()
      |> ForeignKey.new()

    %{rel | foreign_key: fk}
  end
end