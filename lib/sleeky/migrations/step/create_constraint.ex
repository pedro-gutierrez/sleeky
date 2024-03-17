defmodule Sleeky.Migrations.Step.CreateConstraint do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.{Constraint, State}

  defstruct [:constraint]

  @impl true
  def decode(
        {:alter, _,
         [
           {:table, _, [table, table_opts]},
           [do: {:modify, _, [column, {:references, _, [other, opts]}]}]
         ]}
      ) do
    prefix = Keyword.fetch!(table_opts, :prefix)

    constraint =
      opts
      |> Keyword.merge(table: table, prefix: prefix, column: column, target: other)
      |> Constraint.new()

    %__MODULE__{constraint: constraint}
  end

  def decode(_), do: nil

  @impl true
  def encode(step) do
    opts = [prefix: step.constraint.prefix]

    {:alter, [line: 1],
     [
       {:table, [line: 1], [step.constraint.table, opts]},
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

  @impl true
  def aggregate(step, state),
    do: State.add!(state, step.constraint.prefix, :constraints, step.constraint)

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, schema} <- new_state.schemas,
        {constraint_name, constraint} <- schema.constraints do
      if !State.has?(old_state, schema_name, :constraints, constraint_name) do
        %__MODULE__{constraint: constraint}
      else
        nil
      end
    end
  end
end
