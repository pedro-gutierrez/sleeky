defmodule Sleeky.Feature.Policies do
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
      scope: %Sleeky.Scopes.Scope{
        expression: %Sleeky.Scopes.Expression{
          op: op,
          args: args
        }
      }
    }
  end

  defp policy_with_scope!(_model, _action, _role, %{scope: nil} = policy, _), do: policy

  defp policy_with_scope!(model, action, role, policy, all_scopes) do
    case scope(all_scopes, policy.scope) do
      {:ok, scope} ->
        %{policy | scope: scope}

      {:error, reason} ->
        raise """
        Error resolving scope:

            #{inspect(reason)}

        in:

          * action: #{inspect(action.name)}
          * model: #{inspect(model)}
          * role: #{inspect(role)}

        Available scopes:

          #{all_scopes |> Map.keys() |> inspect()}
        """
    end
  end

  defp scope(all_scopes, name) when is_atom(name) do
    case Map.get(all_scopes, name) do
      nil -> {:error, "unknown scope #{inspect(name)}"}
      scope -> {:ok, scope}
    end
  end

  defp scope(all_scopes, {op, scopes}) do
    with scopes when is_list(scopes) <-
           Enum.reduce_while(scopes, [], fn scope, acc ->
             case scope(all_scopes, scope) do
               {:ok, scope} -> {:cont, [scope | acc]}
               {:error, _} = error -> {:halt, error}
             end
           end) do
      {:ok,
       %Sleeky.Scopes.Scope{
         expression: %Sleeky.Scopes.Expression{
           op: op,
           args: Enum.reverse(scopes)
         }
       }}
    end
  end
end
