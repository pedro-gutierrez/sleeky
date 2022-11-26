defmodule Bee.Database.ForeignKey do
  @moduledoc false
  import Bee.Inspector
  alias Bee.Entity.Relation

  defstruct [:name, :table, :column, :target, type: :uuid, null: false, on_delete: :nothing]

  def new(%Relation{kind: :parent} = rel) do
    new(
      name: rel.name,
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

  defp with_name(foreign_key) do
    name = join([foreign_key.table, foreign_key.column])
    %{foreign_key | name: name}
  end

  def from_entity(entity) do
    Enum.map(entity.parents, &new/1)
  end
end
