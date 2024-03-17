defmodule Sleeky.Migrations.Step.DropTable do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.{State, Table}

  defstruct [:table]

  @impl true
  def decode({:drop_if_exists, _, [{:table, _, [name, opts]}]}) do
    prefix = Keyword.fetch!(opts, :prefix)
    table = %Table{prefix: prefix, name: name}

    %__MODULE__{table: table}
  end

  def decode(_), do: nil

  @impl true
  def encode(%__MODULE__{} = step) do
    {:drop_if_exists, [line: 1],
     [
       {:table, [line: 1], [step.table.name, [prefix: step.table.prefix]]}
     ]}
  end

  @impl true
  def aggregate(step, state), do: State.remove!(state, step.table.prefix, :tables, step.table)

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, schema} <- old_state.schemas, {table_name, table} <- schema.tables do
      if !State.has?(new_state, schema_name, :tables, table_name) do
        %__MODULE__{table: table}
      else
        nil
      end
    end
  end
end
