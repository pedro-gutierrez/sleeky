defmodule Sleeky.Authorization.Parser do
  @moduledoc false

  @behaviour Diesel.Parser

  alias Sleeky.Authorization
  alias Sleeky.Authorization.{Expression, Scope}

  @impl true
  def parse({:authorization, opts, children}, _) do
    roles = opts |> Keyword.fetch!(:roles) |> path()

    scopes =
      for {:scope, opts, [{op, _, args}]} <- children do
        name = Keyword.fetch!(opts, :name)
        debug = Keyword.get(opts, :debug, false)
        expression = %Expression{op: op, args: args}

        %Scope{name: name, debug: debug, expression: expression}
      end

    scopes =
      scopes
      |> resolve_expressions()
      |> Enum.reduce(%{}, &Map.put(&2, &1.name, &1))
      |> resolve_scopes()

    %Authorization{roles: roles, scopes: scopes}
  end

  defp resolve_expressions(scopes) do
    for scope <- scopes do
      resolve_expression(scope)
    end
  end

  defp resolve_expression(%{expression: expr} = scope) do
    args = for arg <- expr.args, do: resolve_arg(arg)
    expr = %{expr | args: args}
    %{scope | expression: expr}
  end

  defp resolve_arg(a) when is_binary(a) or is_number(a) or is_atom(a), do: {:value, a}
  defp resolve_arg({:path, [], [path]}), do: {:path, path(path)}
  defp resolve_arg(other), do: other

  defp path(path), do: path |> String.split(".") |> Enum.map(&String.to_atom/1)

  defp resolve_scopes(scopes) do
    scopes
    |> Enum.map(fn {name, scope} ->
      {name, resolve_scope(scope, scopes)}
    end)
    |> Enum.into(%{})
  end

  defp resolve_scope(%{expression: %{op: op} = expr} = scope, scopes) when op in [:one, :all] do
    args =
      for {:value, name} <- expr.args do
        case Map.get(scopes, name) do
          nil ->
            raise_unknown_scope!(name, scope.name, scopes)

          scope ->
            resolve_scope(scope, scopes)
        end
      end

    expr = %{expr | args: args}
    %{scope | expression: expr}
  end

  defp resolve_scope(scope, _scopes) do
    expression = translate_expression(scope.expression.op, scope.expression.args)

    %{scope | expression: expression}
  end

  defp raise_unknown_scope!(name, referenced_by, scopes) do
    raise "Unknown scope #{inspect(name)} referenced by scope #{inspect(referenced_by)}. Available scopes: #{scopes |> Map.keys() |> inspect()}"
  end

  defp translate_expression(:not_nil, [arg]) do
    %Expression{op: :neq, args: [arg, {:value, nil}]}
  end

  defp translate_expression(:same, args) do
    %Expression{op: :eq, args: args}
  end

  defp translate_expression(:member, args) do
    %Expression{op: :in, args: args}
  end

  defp translate_expression(:is_true, [arg]) do
    %Expression{op: :eq, args: [arg, {:value, true}]}
  end

  defp translate_expression(:is_false, [arg]) do
    %Expression{op: :eq, args: [arg, {:value, false}]}
  end

  defp translate_expression(op, args), do: %Expression{op: op, args: args}
end
