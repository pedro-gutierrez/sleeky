defmodule Sleeky.Migrations.Step.CreateTable do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.State
  alias Sleeky.Migrations.Table
  alias Sleeky.Migrations.Column

  import Sleeky.Naming

  defstruct [:table]

  @impl true
  def decode({:create, _, [{:table, _, [name, opts]}, [do: {:__block__, _, columns}]]}) do
    prefix = Keyword.fetch!(opts, :prefix)
    columns = columns |> Column.decode() |> indexed()
    table = %Table{name: name, prefix: prefix, columns: columns}

    %__MODULE__{table: table}
  end

  def decode({:create, _, [{:table, _, [name, opts]}, [do: column]]}) do
    prefix = Keyword.fetch!(opts, :prefix)
    columns = indexed([Column.decode(column)])
    table = %Table{name: name, prefix: prefix, columns: columns}

    %__MODULE__{table: table}
  end

  def decode(_), do: nil

  @impl true
  def encode(%__MODULE__{} = step) do
    opts = [prefix: step.table.prefix, primary_key: false]

    columns =
      step.table.columns
      |> Map.values()
      |> Enum.map(&{:add, [line: 1], Column.encode(&1)})

    columns = columns ++ [{:timestamps, [line: 1], [[type: :utc_datetime_usec]]}]

    {:create, [line: 1],
     [
       {:table, [line: 1], [step.table.name, opts]},
       [
         do: {:__block__, [], columns}
       ]
     ]}
  end

  @impl true
  def aggregate(step, state), do: State.add!(state, step.table.prefix, :tables, step.table)

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, schema} <- new_state.schemas, {table_name, table} <- schema.tables do
      if !State.has?(old_state, schema_name, :tables, table_name) do
        %__MODULE__{table: table}
      else
        nil
      end
    end
  end
end
