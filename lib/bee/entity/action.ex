defmodule Bee.Entity.Action do
  @moduledoc false

  alias Bee.Entity.Summary

  defstruct [
    :name,
    :entity,
    :context_function,
    :aggregate_context_function,
    list?: false,
    custom?: false
  ]

  @built_in [:create, :list, :read, :update, :delete]

  def new(opts) do
    __MODULE__
    |> struct(opts)
    |> with_summary_entity()
    |> maybe_custom_action()
    |> maybe_list_action()
    |> with_context_functions()
  end

  defp with_summary_entity(action) do
    %{action | entity: Summary.new(action.entity)}
  end

  defp maybe_custom_action(action) do
    %{action | custom?: !Enum.member?(@built_in, action.name)}
  end

  defp maybe_list_action(action) do
    %{action | list?: action.name |> to_string() |> String.starts_with?("list")}
  end

  defp with_context_functions(action) do
    if action.list? do
      %{
        action
        | context_function: action_name(action.name, action.entity.plural),
          aggregate_context_function: action_name(:aggregate, action.entity.plural)
      }
    else
      %{action | context_function: action_name(action.name, action.entity.name)}
    end
  end

  defp action_name(action, entity) do
    String.to_atom("#{action}_#{entity}")
  end
end
