defmodule Bee.Migrations.DropIndex do
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
  def decode({:drop_if_exists, _, [{:index, _, [table, _, opts]}]}) do
    name = Keyword.fetch!(opts, :name)

    [name: name, table: table]
    |> Index.new()
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(%__MODULE__{index: index}) do
    {:drop_if_exists, [line: 1], [{:index, [line: 1], [index.table, [], [name: index.name]]}]}
  end

  @impl Step
  def aggregate(%__MODULE__{} = step, state) do
    State.remove!(step.index, :indices, state)
  end

  @impl Step
  def diff(old, new) do
    old.indices
    |> Map.values()
    |> Enum.reject(&State.has?(new, :indices, &1.name))
    |> Enum.map(&new/1)
  end
end
