defmodule Sleeky.Migrations.Table do
  @moduledoc false

  alias Sleeky.Migrations.Column
  alias Sleeky.Migrations.ColumnChanges

  import Sleeky.Naming

  defstruct [
    :name,
    :prefix,
    columns: %{}
  ]

  @timestamps [:inserted_at, :updated_at]

  def from_model(model) do
    prefix = model.domain().name()
    table_name = model.table_name()

    attribute_columns =
      model.attributes()
      |> Enum.reject(&(&1.column_name in @timestamps))
      |> Enum.map(&Column.new/1)

    parent_columns = Enum.map(model.parents(), &Column.new/1)

    columns = indexed(attribute_columns ++ parent_columns)

    %__MODULE__{name: table_name, prefix: prefix, columns: columns}
  end

  def column!(table, name) do
    with nil <- Map.get(table.columns, name) do
      column_names = Map.keys(table.columns)

      raise "No column #{inspect(name)} in table #{inspect(table.name)} with columns: #{inspect(column_names)} "
    end
  end

  def modify_column(%Column{} = column, %ColumnChanges{} = changes, %__MODULE__{} = table) do
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
