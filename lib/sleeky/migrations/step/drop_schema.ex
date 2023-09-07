defmodule Sleeky.Migrations.Step.DropSchema do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.State

  defstruct [:schema]

  @impl true
  def decode({:execute, _, ["DROP SCHEMA " <> schema]}) do
    schema = String.to_atom(schema)

    %__MODULE__{schema: schema}
  end

  def decode(_), do: nil

  @impl true
  def encode(step), do: {:execute, [line: 1], ["DROP SCHEMA #{step.schema}"]}

  @impl true
  def aggregate(step, state), do: State.remove_schema(state, step.schema)

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, _} <- old_state.schemas do
      if !State.has_schema?(new_state, schema_name) do
        %__MODULE__{schema: schema_name}
      else
        nil
      end
    end
  end
end
