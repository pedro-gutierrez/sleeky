defmodule Bee.Migrations.DropConstraint do
  @moduledoc false
  use Bee.Migrations.Step

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
  def diff(old, new) do
    old.constraints
    |> Map.values()
    |> Enum.reject(&State.has?(new, :constraints, &1.name))
    |> Enum.map(&new/1)
  end
end
