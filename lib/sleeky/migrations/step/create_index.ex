defmodule Sleeky.Migrations.Step.CreateIndex do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step

  alias Sleeky.Migrations.{Index, State}

  defstruct [:index]

  @impl true
  def decode({:create, _, [{:unique_index, _, [table, columns, opts]}]}) do
    name = Keyword.fetch!(opts, :name)
    prefix = Keyword.fetch!(opts, :prefix)

    index =
      Index.from_opts(table: table, prefix: prefix, columns: columns, name: name, unique: true)

    %__MODULE__{index: index}
  end

  def decode({:create, _, [{:index, _, [table, columns, opts]}]}) do
    name = Keyword.fetch!(opts, :name)
    prefix = Keyword.fetch!(opts, :prefix)

    index =
      Index.from_opts(table: table, prefix: prefix, columns: columns, name: name, unique: false)

    %__MODULE__{index: index}
  end

  def decode(_), do: nil

  @impl true
  def encode(%__MODULE__{} = step) do
    kind = if step.index.unique, do: :unique_index, else: :index
    opts = [name: step.index.name, prefix: step.index.prefix]

    {:create, [line: 1],
     [
       {kind, [line: 1], [step.index.table, step.index.columns, opts]}
     ]}
  end

  @impl true
  def aggregate(%__MODULE__{} = step, state),
    do: State.add!(state, step.index.prefix, :indexes, step.index)

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, schema} <- new_state.schemas, {index_name, index} <- schema.indexes do
      if !State.has?(old_state, schema_name, :indexes, index_name) do
        %__MODULE__{index: index}
      else
        nil
      end
    end
  end
end
