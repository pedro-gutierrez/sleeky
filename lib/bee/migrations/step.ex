defmodule Bee.Migrations.Step do
  @moduledoc false

  alias Bee.Database.State
  import Bee.Inspector

  @type step :: struct()
  @type code :: tuple()

  @callback encode(step()) :: code()
  @callback decode(code()) :: step()
  @callback aggregate(step(), State.t()) :: State.t()
  @callback diff(State.t(), State.t()) :: [step()]

  defmacro __using__(_opts) do
    {action, item} = action_item(__CALLER__.module)

    action = aggregate_action(action)

    state_key = state_key(item)

    quote do
      @behaviour Bee.Migrations.Step
      alias Bee.Migrations.Step
      alias Bee.Database.Constraint
      alias Bee.Database.State
      alias Bee.Database.Table

      @impl Step
      def aggregate(step, state) do
        State.unquote(action)(step.unquote(item), unquote(state_key), state)
      end
    end
  end

  defp action_item(module) do
    [action | item] =
      module
      |> Module.split()
      |> List.last()
      |> Inflex.underscore()
      |> String.split("_")

    {action, join(item)}
  end

  defp state_key(item) do
    item |> Inflex.pluralize() |> String.to_atom()
  end

  defp aggregate_action("create"), do: :add_new!
  defp aggregate_action("drop"), do: :remove_existing!
end
