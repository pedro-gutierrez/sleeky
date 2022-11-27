defmodule Bee.Database.Table do
  @moduledoc false
  alias Bee.Database.Column
  alias Bee.Database.ColumnOpts
  import Bee.Inspector

  defstruct [
    :name,
    columns: %{}
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def from_entity(entity) do
    name = entity.table()

    attribute_columns =
      entity.attributes()
      |> Enum.reject(&(&1.virtual || &1.timestamp))
      |> Enum.map(&Column.new/1)

    parent_columns = Enum.map(entity.parents(), &Column.new/1)

    columns = indexed(attribute_columns ++ parent_columns)

    %__MODULE__{name: name, columns: columns}
  end

  def column!(table, name) do
    with nil <- Map.fetch!(table.columns, name) do
      column_names = Map.keys(table.columns)

      raise "No column #{inspect(name)} in table #{inspect(table.name)}: #{inspect(column_names)} "
    end
  end

  def modify_column(%Column{} = column, %ColumnOpts{} = changes, %__MODULE__{} = table) do
    column = Column.apply_changes(column, changes)
    columns = Map.put(table.columns, column.name, column)

    %{table | columns: columns}
  end

  def add_column(%Column{} = col, %__MODULE__{} = table) do
    columns = Map.put(table.columns, col.name, col)
    %{table | columns: columns}
  end

  def remove_column(%Column{} = col, %__MODULE__{} = table) do
    columns = Map.drop(table.columns, [col.name])
    %{table | columns: columns}
  end
end
