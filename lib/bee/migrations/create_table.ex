defmodule Bee.Migrations.CreateTable do
  @moduledoc false
  use Bee.Migrations.Step

  alias Bee.Database.State
  alias Bee.Database.Table
  alias Bee.Database.Column
  alias Bee.Migrations.Step

  defstruct [:table]

  def new(table) do
    %__MODULE__{table: table}
  end

  @impl Step
  def decode({:create, _, [{:table, _, [name, _opts]}, [do: {:__block__, _, columns}]]}) do
    columns = Column.decode(columns)

    [name: name, columns: columns]
    |> Table.new()
    |> new()
  end

  def decode({:create, _, [{:table, _, [name, _opts]}, [do: column]]}) do
    [name: name, columns: [Column.decode(column)]]
    |> Table.new()
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(%__MODULE__{} = step) do
    columns =
      Enum.map(step.table.columns, fn col ->
        {:add, [line: 1], Column.encode(col)}
      end)

    {:create, [line: 1],
     [
       {:table, [line: 1], [step.table.name, [primary_key: false]]},
       [
         do: {:__block__, [], columns ++ [{:timestamps, [line: 1], []}]}
       ]
     ]}
  end

  @impl Step
  def diff(old, new) do
    new.tables
    |> Map.values()
    |> Enum.reject(&State.has?(old, :tables, &1.name))
    |> Enum.map(&new/1)
  end
end
