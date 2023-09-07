defmodule Sleeky.Migrations.Constraint do
  @moduledoc false
  import Sleeky.Inspector
  alias Sleeky.Model.Relation

  defstruct [
    :name,
    :table,
    :prefix,
    :column,
    :target,
    type: :uuid,
    null: false,
    on_delete: :nothing
  ]

  def from_relation(%Relation{kind: :parent} = rel) do
    target_model = rel.target.module

    new(
      table: rel.model.table_name(),
      prefix: rel.model.context.name(),
      column: rel.column_name,
      target: target_model.table_name(),
      type: target_model.primary_key().storage,
      null: !rel.required?
    )
  end

  def new(opts) do
    __MODULE__
    |> struct(opts)
    |> with_name()
  end

  defp with_name(constraint) do
    if is_nil(constraint.name) do
      name = join([constraint.table, constraint.column, "fkey"])
      %{constraint | name: name}
    else
      constraint
    end
  end

  def all_from_entity(entity) do
    Enum.map(entity.parents, &new/1)
  end
end
