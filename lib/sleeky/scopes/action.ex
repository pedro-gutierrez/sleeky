defmodule Sleeky.Scopes.Action do
  @moduledoc false

  def allow?(_entity, _action, nil, _params), do: false

  def allow?(entity, action, policy, params) do
    if policy.scope do
      scope_allowed?(entity, action, policy.scope, params)
    else
      true
    end
  end

  defp scope_allowed?(entity, action, %{expression: %{op: :one} = expr}, params) do
    Enum.reduce_while(expr.args, false, fn scope, default ->
      if scope_allowed?(entity, action, scope, params) do
        {:halt, true}
      else
        {:cont, default}
      end
    end)
  end

  defp scope_allowed?(entity, action, %{expression: %{op: :all} = expr}, params) do
    Enum.reduce_while(expr.args, false, fn scope, default ->
      if scope_allowed?(entity, action, scope, params) do
        {:cont, true}
      else
        {:halt, default}
      end
    end)
  end

  defp scope_allowed?(entity, action, scope, params) do
    values = for arg <- scope.expression.args, do: Sleeky.Evaluate.evaluate(params, arg)
    result = Sleeky.Compare.compare(scope.expression.op, values)

    if scope.debug do
      IO.inspect(
        entity: entity,
        action: action,
        scope: scope,
        params: params,
        values: values,
        result: result
      )
    end

    result
  end
end
