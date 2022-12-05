defmodule Bee.Migrations.CreateIndex do
  @moduledoc false
  @behaviour Bee.Migrations.Step

  alias Bee.Database.Index
  alias Bee.Database.State
  alias Bee.Migrations.Step

  defstruct [:index]

  def new(index) do
    %__MODULE__{index: index}
  end

  @impl Step
  def decode({:create, _, [{:unique_index, _, [table, columns, [name: name]]}]}) do
    Index.new(table: table, columns: columns, name: name, unique: true)
    |> new()
  end

  def decode({:create, _, [{:index, _, [table, columns, [name: name]]}]}) do
    Index.new(table: table, columns: columns, name: name, unique: false)
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(%__MODULE__{index: index}) do
    kind = if index.unique, do: :unique_index, else: :index

    {:create, [line: 1],
     [
       {kind, [line: 1], [index.table, index.columns, [name: index.name]]}
     ]}
  end

  @impl Step
  def aggregate(%__MODULE__{} = step, state) do
    State.add!(step.index, :indices, state)
  end

  @impl Step
  def diff(old, new) do
    new.indices
    |> Map.values()
    |> Enum.reject(&State.has?(old, :indices, &1.name))
    |> Enum.map(&new/1)
  end
end
