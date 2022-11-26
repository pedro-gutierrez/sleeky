defmodule Bee.Migrations.CreateForeignKey do
  @moduledoc false
  use Bee.Migrations.Step

  defstruct [:foreign_key]

  def new(key) do
    %__MODULE__{foreign_key: key}
  end

  @impl Step
  def decode(
        {:alter, _,
         [{:table, _, [table]}, [do: {:modify, _, [column, {:references, _, [other, opts]}]}]]}
      ) do
    [table: table, column: column, target: other]
    |> Keyword.merge(opts)
    |> ForeignKey.new()
    |> new()
  end

  def decode(_), do: nil

  @impl Step
  def encode(step) do
    {:alter, [line: 1],
     [
       {:table, [line: 1], [step.foreign_key.table]},
       [
         do:
           {:modify, [line: 1],
            [
              step.foreign_key.column,
              {:references, [line: 1],
               [
                 step.foreign_key.target,
                 [
                   type: step.foreign_key.type,
                   null: step.foreign_key.null,
                   on_delete: step.foreign_key.on_delete
                 ]
               ]}
            ]}
       ]
     ]}
  end

  @impl Step
  def diff(old, new) do
    new.foreign_keys
    |> Map.values()
    |> Enum.reject(&State.has?(old, :foreign_keys, &1.name))
    |> Enum.map(&new/1)
  end
end
