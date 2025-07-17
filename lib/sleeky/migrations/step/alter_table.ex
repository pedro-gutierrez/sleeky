defmodule Sleeky.Migrations.Step.AlterTable do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.{Column, ColumnChanges, State, Table}

  import Sleeky.Naming

  defstruct [:table, :prefix, add: %{}, remove: %{}, modify: %{}]

  @impl true
  def decode({:alter, _, [{:table, _, [table, opts]}, [do: {:__block__, _, columns}]]})
      when is_list(columns) do
    prefix = Keyword.fetch!(opts, :prefix)
    columns = columns |> Enum.map(&decode/1) |> Enum.reject(&is_nil/1)
    new(table, prefix, columns)
  end

  def decode({:alter, _, [{:table, _, [table, opts]}, [do: column]]}) do
    prefix = Keyword.fetch!(opts, :prefix)

    columns =
      case decode(column) do
        nil -> []
        column -> [column]
      end

    new(table, prefix, columns)
  end

  def decode({:add, _, col}), do: {:add, Column.new(col)}
  def decode({:modify, _, col}), do: {:modify, ColumnChanges.decode(col)}
  def decode({:remove, _, [name]}), do: {:remove, Column.new(name)}
  def decode(_), do: nil

  @impl true
  def encode(step) do
    opts = [prefix: step.prefix]
    add = step.add |> Map.values() |> Enum.map(&{:add, [line: 1], Column.encode(&1)})
    remove = step.remove |> Map.values() |> Enum.map(&{:remove, [line: 1], [&1.name]})
    modify = step.modify |> Map.values() |> Enum.map(&{:modify, [line: 1], Column.encode(&1)})

    {:alter, [line: 1],
     [
       {:table, [line: 1], [step.table, opts]},
       [do: {:__block__, [], add ++ remove ++ modify}]
     ]}
  end

  @impl true
  def aggregate(step, state) do
    table =
      state
      |> State.find!(step.prefix, :tables, step.table)
      |> apply_changes(step)

    State.replace!(state, table.prefix, :tables, table)
  end

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, schema} <- new_state.schemas,
        {table_name, table} <- schema.tables do
      with %Table{} = old_table <- State.find(old_state, schema_name, :tables, table_name) do
        diff_tables(old_table, table)
      else
        _ -> nil
      end
    end
  end

  def diff_tables(old_table, new_table) do
    add = added_columns(old_table, new_table)
    remove = removed_columns(old_table, new_table)
    modify = modified_columns(old_table, new_table)

    case map_size(add) + map_size(remove) + map_size(modify) do
      0 -> nil
      _ -> new(new_table.name, new_table.prefix, add, remove, modify)
    end
  end

  defp apply_changes(table, step) do
    table
    |> with_added_columns(step)
    |> with_removed_columns(step)
    |> with_modified_columns(step)
  end

  defp with_added_columns(table, step) do
    step.add
    |> Map.values()
    |> Enum.reduce(table, &Table.add_column/2)
  end

  defp with_removed_columns(table, step) do
    step.remove
    |> Map.values()
    |> Enum.reduce(table, &Table.remove_column/2)
  end

  defp with_modified_columns(table, step) do
    step.modify
    |> Map.values()
    |> Enum.reduce(table, fn changes, table ->
      table
      |> Table.column!(changes.name)
      |> Table.modify_column(changes, table)
    end)
  end

  defp added_columns(old_table, new_table) do
    new_columns = Map.keys(new_table.columns) -- Map.keys(old_table.columns)
    Map.take(new_table.columns, new_columns)
  end

  defp removed_columns(old_table, new_table) do
    old_columns = Map.keys(old_table.columns) -- Map.keys(new_table.columns)

    old_columns
    |> Enum.map(&Column.new/1)
    |> indexed()
  end

  defp modified_columns(old_table, new_table) do
    new_columns = Map.keys(new_table.columns)
    old_columns = Map.keys(old_table.columns)
    in_common = new_columns -- new_columns -- old_columns

    in_common
    |> Enum.map(fn name ->
      old_column = Map.fetch!(old_table.columns, name)
      new_column = Map.fetch!(new_table.columns, name)

      Column.diff(old_column, new_column)
    end)
    |> Enum.reject(&ColumnChanges.empty?/1)
    |> indexed()
  end

  defp new(table, prefix, columns) do
    step = %__MODULE__{table: table, prefix: prefix}

    Enum.reduce(columns, step, fn {bag, column}, step ->
      columns = step |> Map.get(bag) |> Map.put(column.name, column)
      Map.put(step, bag, columns)
    end)
  end

  defp new(table, prefix, add, remove, modify) do
    struct(__MODULE__, table: table, prefix: prefix, add: add, remove: remove, modify: modify)
  end
end
