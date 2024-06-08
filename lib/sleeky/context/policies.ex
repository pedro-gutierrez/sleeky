defmodule Sleeky.Context.Policies do
  @moduledoc false

  def resolve!(model, action, scopes) do
    for {role, policy} <- action.policies, into: %{} do
      {role, policy_with_scope!(model, action, role, policy, scopes)}
    end
  end

  def reduce(policies, roles) do
    roles
    |> Enum.map(&Map.get(policies, &1))
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> nil
      [policy] -> policy
      policies -> combine(policies, :one)
    end
  end

  def combine(policies, op) when op in [:one, :all] do
    args = for policy <- policies, do: policy.scope

    %Sleeky.Model.Policy{
      scope: %Sleeky.Authorization.Scope{
        expression: %Sleeky.Authorization.Expression{
          op: op,
          args: args
        }
      }
    }
  end

  defp policy_with_scope!(_model, _action, _role, %{scope: nil} = policy, _), do: policy

  defp policy_with_scope!(model, action, role, policy, scopes) do
    scope = Map.get(scopes, policy.scope)

    unless scope do
      raise """
        Unknown scope: #{inspect(policy.scope)}
        in action: #{inspect(action.name)}
        for role: #{inspect(role)}
        of model: #{inspect(model)}

        Available scopes: #{scopes |> Map.keys() |> inspect()}
      """
    end

    %{policy | scope: scope}
  end
end
