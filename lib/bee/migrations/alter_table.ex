defmodule Bee.Migrations.AlterTable do
  @moduledoc false
  @behaviour Bee.Migrations.Step

  alias Bee.Database.Table
  alias Bee.Database.Column
  alias Bee.Database.ColumnChanges
  alias Bee.Database.State
  alias Bee.Migrations.Step

  import Bee.Inspector

  defstruct [:table, add: %{}, remove: %{}, modify: %{}]

  def new(table, columns) do
    step = %__MODULE__{table: table}

    Enum.reduce(columns, step, fn {bag, column}, step ->
      columns = step |> Map.get(bag) |> Map.put(column.name, column)
      Map.put(step, bag, columns)
    end)
  end

  def new(table, add, remove, modify) do
    struct(__MODULE__, table: table, add: add, remove: remove, modify: modify)
  end

  @impl Step
  def decode({:alter, _, [{:table, _, [table]}, [do: {:__block__, _, [columns]}]]}) do
    columns = Enum.map(columns, &decode/1)
    new(table, columns)
  end

  def decode({:alter, _, [{:table, _, [table]}, [do: column]]}) do
    new(table, [decode(column)])
  end

  def decode({:add, _, col}), do: {:add, Column.new(col)}
  def decode({:modify, _, col}), do: {:modify, ColumnChanges.decode(col)}
  def decode({:remove, _, [name]}), do: {:remove, Column.new(name)}

  def decode(_), do: nil

  @impl Step
  def encode(step) do
    IO.inspect(step)
    add = step.add |> Map.values() |> Enum.map(&{:add, [line: 1], Column.encode(&1)})
    remove = step.remove |> Map.values() |> Enum.map(&{:remove, [line: 1], [&1.name]})
    modify = step.modify |> Map.values() |> Enum.map(&{:modify, [line: 1], Column.encode(&1)})

    {:alter, [line: 1],
     [
       {:table, [line: 1], [step.table]},
       [do: {:__block__, [], add ++ remove ++ modify}]
     ]}
  end

  @impl Step
  def aggregate(step, state) do
    table =
      step.table
      |> State.find!(:tables, state)
      |> apply_changes(step)

    State.replace!(table, :tables, state)
  end

  @impl Step
  def diff(old_state, new_state) do
    table_names = Map.keys(new_state.tables)

    old_state.tables
    |> Map.take(table_names)
    |> Map.values()
    |> Enum.map(&{&1, State.find!(&1.name, :tables, new_state)})
    |> Enum.map(&diff/1)
  end

  def diff({old_table, new_table}) do
    add = added_columns(old_table, new_table)
    remove = removed_columns(old_table, new_table)
    modify = modified_columns(old_table, new_table)

    case map_size(add) + map_size(remove) + map_size(modify) do
      0 -> nil
      _ -> new(new_table.name, add, remove, modify)
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
end
