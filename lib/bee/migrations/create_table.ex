defmodule Bee.Migrations.CreateTable do
  @moduledoc false
  alias Bee.Migrations.State
  alias Bee.Migrations.Step
  alias Bee.Migrations.Table
  alias Bee.Migrations.Column

  @behaviour Bee.Migrations.Step

  defstruct [:table]

  def new(table) do
    %__MODULE__{table: table}
  end

  @impl Step
  def decode({:create, _, [{:table, _, [name, _opts]}, [do: {:__block__, _, columns}]]}) do
    [name: name, columns: columns]
    |> Table.new()
    |> new()
  end

  def decode({:create, _, [{:table, _, [name, _opts]}, [do: column]]}) do
    [name: name, columns: [column]]
    |> Table.new()
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(%__MODULE__{} = step) do
    columns =
      Enum.map(step.table.columns, fn col ->
        args = Column.encode_args(col)

        {:add, [line: 1], args}
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
  def aggregate(%__MODULE__{} = step, state) do
    State.add_new!(step.table, :tables, state)
  end

  @impl Step
  def diff(old, new) do
    Enum.map(new.tables, fn {_, table} ->
      if !State.table?(old, table.name) do
        new(table)
      else
        nil
      end
    end)
  end
end
