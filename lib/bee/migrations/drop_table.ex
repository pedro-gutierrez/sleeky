defmodule Sleeki.Migrations.DropTable do
  @moduledoc false
  @behaviour Sleeki.Migrations.Step

  alias Sleeki.Database.State
  alias Sleeki.Database.Table
  alias Sleeki.Migrations.Step

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
  def aggregate(step, state) do
    State.remove!(step.table, :tables, state)
  end

  @impl Step
  def diff(old, new) do
    Enum.map(old.tables, fn {_, table} ->
      if !State.has?(new, :tables, table.name) do
        new(table)
      else
        nil
      end
    end)
  end
end
