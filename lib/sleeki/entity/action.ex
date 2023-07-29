defmodule Sleeki.Entity.Action do
  @moduledoc false

  alias Sleeki.Entity.Summary
  import Sleeki.Inspector

  defstruct [
    :name,
    :entity,
    :label,
    list?: false,
    custom?: false,
    policies: []
  ]

  @built_in [:create, :list, :read, :update, :delete]

  def new(opts) do
    __MODULE__
    |> struct(opts)
    |> with_label()
    |> with_summary_entity()
    |> maybe_custom_action()
    |> maybe_list_action()
  end

  defp with_label(action) do
    %{action | label: label(action.name)}
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

  def with_policies(action, nil), do: action

  def with_policies(action, block) do
    %{action | policies: policies_from(block)}
  end

  defp policies_from(do: item) do
    policies_from(item)
  end

  defp policies_from({:__block__, _, items}) do
    policies_from(items)
  end

  defp policies_from(items) when is_list(items) do
    items
    |> Enum.map(fn
      {:allow, _, [role, [do: {:scope, _, [scope]}]]} -> {role, scope}
      {:allow, _, [role, scope]} -> {role, scope}
      {:allow, _, [role]} -> {role, :any}
    end)
    |> Enum.into(%{})
  end

  defp policies_from(item), do: policies_from([item])

  def resolve_policies(%__MODULE__{} = action, scopes) do
    for {role, scope} <- action.policies, into: %{} do
      case Map.get(scopes, scope) do
        nil ->
          raise "unknown scope #{inspect(scope)} in action #{inspect(action.name)} of entity
            #{inspect(action.entity.name)} for role #{inspect(role)}. Known scopes are: #{inspect(Map.keys(scopes))}"

        scope ->
          {role, scope}
      end
    end
  end
end
