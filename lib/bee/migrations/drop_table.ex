defmodule Bee.Migrations.DropTable do
  @moduledoc false
  alias Bee.Migrations.State
  alias Bee.Migrations.Step
  alias Bee.Migrations.Table

  @behaviour Bee.Migrations.Step

  defstruct [:table]

  def new(table) do
    %__MODULE__{table: table}
  end

  @impl Step
  def decode({:drop_if_exists, _, [{:table, _, [name]}]}) do
    [name: name]
    |> Table.new()
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(%__MODULE__{} = step) do
    {:drop_if_exists, [line: 1],
     [
       {:table, [line: 1], [step.table.name]}
     ]}
  end

  @impl Step
  def aggregate(%__MODULE__{} = step, state) do
    State.remove_existing!(step.table, :tables, state)
  end

  @impl Step
  def diff(old, new) do
    Enum.map(old.tables, fn {_, table} ->
      if !State.table?(new, table.name) do
        new(table)
      else
        nil
      end
    end)
  end
end
