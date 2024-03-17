defmodule Sleeky.Migrations.Step.DropIndex do
  @moduledoc false
  @behaviour Sleeky.Migrations.Step
  alias Sleeky.Migrations.{Index, State}

  defstruct [:index]

  @impl true
  def decode({:drop_if_exists, _, [{:index, _, [table, _, opts]}]}) do
    name = Keyword.fetch!(opts, :name)
    prefix = Keyword.fetch!(opts, :prefix)
    index = Index.from_opts(name: name, table: table, prefix: prefix)

    %__MODULE__{index: index}
  end

  def decode(_), do: nil

  @impl true
  def encode(%__MODULE__{index: index}) do
    opts = [name: index.name, prefix: index.prefix]

    {:drop_if_exists, [line: 1], [{:index, [line: 1], [index.table, [], opts]}]}
  end

  @impl true
  def aggregate(%__MODULE__{} = step, state),
    do: State.remove!(state, step.index.prefix, :indexes, step.index)

  @impl true
  def diff(old_state, new_state) do
    for {schema_name, schema} <- old_state.schemas, {index_name, index} <- schema.indexes do
      if !State.has?(new_state, schema_name, :indexes, index_name) do
        %__MODULE__{index: index}
      else
        nil
      end
    end
  end
end
