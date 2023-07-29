defmodule Sleeky.Database.Index do
  @moduledoc false

  alias Sleeky.Entity.Key
  import Sleeky.Inspector

  defstruct [:name, :table, :columns, unique: false]

  def new(%Key{} = key) do
    columns = Enum.map(key.fields, & &1.column)

    new(unique: key.unique, columns: columns, table: key.entity.table)
  end

  def new(opts) do
    __MODULE__
    |> struct(opts)
    |> with_name()
  end

  defp with_name(index) do
    if is_nil(index.name) do
      parts = [index.table] ++ index.columns ++ ["idx"]
      name = join(parts)
      %{index | name: name}
    else
      index
    end
  end

  def all_from_entity(entity) do
    Enum.map(entity.keys(), &new/1)
  end
end
