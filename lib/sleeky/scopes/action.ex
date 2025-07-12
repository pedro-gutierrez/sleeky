defmodule Sleeky.Scopes.Action do
  @moduledoc false

  def allow?(_model, _action, nil, _params), do: false

  def allow?(model, action, policy, params) do
    if policy.scope do
      scope_allowed?(model, action, policy.scope, params)
    else
      true
    end
  end

  defp scope_allowed?(model, action, %{expression: %{op: :one} = expr}, params) do
    Enum.reduce_while(expr.args, false, fn scope, default ->
      if scope_allowed?(model, action, scope, params) do
        {:halt, true}
      else
        {:cont, default}
      end
    end)
  end

  defp scope_allowed?(model, action, %{expression: %{op: :all} = expr}, params) do
    Enum.reduce_while(expr.args, false, fn scope, default ->
      if scope_allowed?(model, action, scope, params) do
        {:cont, true}
      else
        {:halt, default}
      end
    end)
  end

  defp scope_allowed?(model, action, scope, params) do
    values = for arg <- scope.expression.args, do: Sleeky.Evaluate.evaluate(params, arg)
    result = Sleeky.Compare.compare(scope.expression.op, values)

    if scope.debug do
      IO.inspect(
        model: model,
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
