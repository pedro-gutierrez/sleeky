defmodule Bee.Auth.Scope.Parser do
  @moduledoc false

  alias Bee.Auth.Scope

  import Bee.Inspector

  def parse(name, do: expr) do
    parse(name, expr)
  end

  def parse(name, expr) do
    expr = expression(expr)

    Scope.new(name: name, expression: expr)
  end

  defp expression({:any, _, exprs}) do
    %{any: Enum.map(exprs, &expression/1)}
  end

  defp expression({:all, _, exprs}) do
    %{all: Enum.map(exprs, &expression/1)}
  end

  defp expression({op, _, [prop, value]}) do
    %{op: op(op), prop: prop(prop), value: value(value)}
  end

  defp expression({:not, _, [expr]}) do
    expr
    |> expression()
    |> negate()
  end

  defp expression(name) when is_atom(name), do: name

  defp negate(expr) when is_map(expr) do
    Map.put(expr, :op, negate(expr[:op]))
  end

  defp negate(:in), do: :not_in
  defp negate(:eq), do: :neq

  defp value({:env, _, [app, {:__aliases__, _, env}, key]}) do
    %{app: app, env: Module.concat(env), key: key}
  end

  defp value(v) when is_boolean(v), do: {:literal, v}
  defp value({:literal, _, [v]}), do: {:literal, v}

  defp value(v) when is_binary(v) do
    tokenize(v)
  end

  defp value([v | _] = values) when is_binary(v) do
    Enum.map(values, &value/1)
  end

  defp value(other), do: other

  defp prop(v) do
    tokenize(v)
  end

  defp op(:==), do: :eq
  defp op(op) when is_atom(op), do: op
  defp op(other), do: raise("scope operator #{inspect(other)} is not supported")
end
