defmodule Sleeky.Migrations.Step.DropConstraint do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.{Constraint, State}

  defstruct [:constraint]

  @impl true
  def decode({:drop_if_exists, _, [{:constraint, _, [table, name, opts]}]}) do
    prefix = Keyword.fetch!(opts, :prefix)
    constraint = Constraint.new(name: name, table: table, prefix: prefix)

    %__MODULE__{constraint: constraint}
  end

  def decode(_), do: nil

  @impl true
  def encode(step) do
    opts = [prefix: step.constraint.prefix]

    {:drop_if_exists, [line: 1],
     [{:constraint, [line: 1], [step.constraint.table, step.constraint.name, opts]}]}
  end

  @impl true
  def aggregate(step, state),
    do: State.remove!(state, step.constraint.prefix, :constraints, step.constraint)

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, schema} <- old_state.schemas,
        {constraint_name, constraint} <- schema.constraints do
      if !State.has?(new_state, schema_name, :constraints, constraint_name) do
        %__MODULE__{constraint: constraint}
      else
        nil
      end
    end
  end
end
