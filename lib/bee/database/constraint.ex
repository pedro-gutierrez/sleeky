defmodule Bee.Database.Constraint do
  @moduledoc false
  import Bee.Inspector
  alias Bee.Entity.Relation

  defstruct [:name, :table, :column, :target, type: :uuid, null: false, on_delete: :nothing]

  def new(%Relation{kind: :parent} = rel) do
    new(
      table: rel.entity.table,
      column: rel.column,
      target: rel.target.table,
      null: !rel.required
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

  def from_entity(entity) do
    Enum.map(entity.parents, &new/1)
  end
end
