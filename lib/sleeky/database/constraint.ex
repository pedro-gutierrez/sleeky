defmodule Sleeky.Database.Constraint do
  @moduledoc false
  import Sleeky.Inspector
  alias Sleeky.Entity.Relation

  defstruct [:name, :table, :column, :target, type: :uuid, null: false, on_delete: :nothing]

  def new(%Relation{kind: :parent} = rel) do
    target_pk = rel.target.module.primary_key()

    new(
      table: rel.entity.table,
      column: rel.column,
      target: rel.target.table,
      type: target_pk.storage,
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
