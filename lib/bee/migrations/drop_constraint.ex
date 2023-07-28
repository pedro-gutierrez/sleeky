defmodule Sleeki.Migrations.DropConstraint do
  @moduledoc false
  @behaviour Sleeki.Migrations.Step

  alias Sleeki.Database.Constraint
  alias Sleeki.Database.State
  alias Sleeki.Migrations.Step

  defstruct [:constraint]

  def new(key) do
    %__MODULE__{constraint: key}
  end

  @impl Step
  def decode({:drop_if_exists, _, [{:constraint, _, [table, name]}]}) do
    [name: name, table: table]
    |> Constraint.new()
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(step) do
    {:drop_if_exists, [line: 1],
     [{:constraint, [line: 1], [step.constraint.table, step.constraint.name]}]}
  end

  @impl Step
  def aggregate(step, state) do
    State.remove!(step.constraint, :constraints, state)
  end

  @impl Step
  def diff(old, new) do
    old.constraints
    |> Map.values()
    |> Enum.reject(&State.has?(new, :constraints, &1.name))
    |> Enum.map(&new/1)
  end
end
