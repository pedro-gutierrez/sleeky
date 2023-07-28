defmodule Sleeki.Migrations.CreateConstraint do
  @moduledoc false
  @behaviour Sleeki.Migrations.Step

  alias Sleeki.Migrations.Step
  alias Sleeki.Database.Constraint
  alias Sleeki.Database.State

  defstruct [:constraint]

  def new(key) do
    %__MODULE__{constraint: key}
  end

  @impl Step
  def decode(
        {:alter, _,
         [{:table, _, [table]}, [do: {:modify, _, [column, {:references, _, [other, opts]}]}]]}
      ) do
    [table: table, column: column, target: other]
    |> Keyword.merge(opts)
    |> Constraint.new()
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(step) do
    {:alter, [line: 1],
     [
       {:table, [line: 1], [step.constraint.table]},
       [
         do:
           {:modify, [line: 1],
            [
              step.constraint.column,
              {:references, [line: 1],
               [
                 step.constraint.target,
                 [
                   type: step.constraint.type,
                   null: step.constraint.null,
                   on_delete: step.constraint.on_delete
                 ]
               ]}
            ]}
       ]
     ]}
  end

  @impl Step
  def aggregate(step, state) do
    State.add!(step.constraint, :constraints, state)
  end

  @impl Step
  def diff(old, new) do
    new.constraints
    |> Map.values()
    |> Enum.reject(&State.has?(old, :constraints, &1.name))
    |> Enum.map(&new/1)
  end
end
