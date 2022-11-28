defmodule Bee.Migrations.CreateIndex do
  @moduledoc false
  @behaviour Bee.Migrations.Step

  alias Bee.Database.State
  alias Bee.Migrations.Step

  import Bee.Inspector

  defstruct [:index]

  def new(index) do
    %__MODULE__{index: index}
  end

  @impl Step
  def decode({:create, _, [{:unique_index, _, [table, columns, [name: name]]}]}) do
    Index.new(table, columns: columns, name: name, unique: true)
    |> new()
  end

  def decode({:create, _, [{:index, _, [table, columns, [name: name]]}]}) do
    Index.new(table, columns: columns, name: name, unique: false)
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(%__MODULE__{} = step) do
    columns =
      step.table.columns
      |> Map.values()
      |> Enum.map(&{:add, [line: 1], Column.encode(&1)})

    {:create, [line: 1],
     [
       {:table, [line: 1], [step.table.name, [primary_key: false]]},
       [
         do: {:__block__, [], columns ++ [{:timestamps, [line: 1], []}]}
       ]
     ]}
  end

  @impl Step
  def aggregate(step, state) do
    State.add!(step.table, :tables, state)
  end

  @impl Step
  def diff(old, new) do
    new.tables
    |> Map.values()
    |> Enum.reject(&State.has?(old, :tables, &1.name))
    |> Enum.map(&new/1)
  end
end
