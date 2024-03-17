defmodule Sleeky.Migrations.Step.CreateSchema do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.State

  defstruct [:schema]

  @impl true
  def decode({:execute, _, ["CREATE SCHEMA " <> schema]}) do
    schema = String.to_atom(schema)

    %__MODULE__{schema: schema}
  end

  def decode(_), do: nil

  @impl true
  def encode(step), do: {:execute, [line: 1], ["CREATE SCHEMA #{step.schema}"]}

  @impl true
  def aggregate(step, state), do: State.add_schema(state, step.schema)

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, _} <- new_state.schemas do
      if !State.has_schema?(old_state, schema_name) do
        %__MODULE__{schema: schema_name}
      else
        nil
      end
    end
  end
end
