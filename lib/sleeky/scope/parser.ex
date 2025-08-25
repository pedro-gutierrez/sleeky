defmodule Sleeky.Scope.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Scope
  alias Sleeky.Scope.Expression

  @impl true
  def parse({:scope, attrs, [{op, _, args}]}, opts) do
    name =
      opts
      |> Keyword.fetch!(:caller_module)
      |> Module.split()
      |> List.last()
      |> Macro.underscore()
      |> String.to_atom()

    debug = Keyword.get(attrs, :debug, false)
    args = Enum.map(args, &resolve_arg/1)
    expression = expression(op, args)

    %Scope{name: name, debug: debug, expression: expression}
  end

  defp resolve_arg(a) when is_binary(a) or is_number(a), do: {:value, a}

  defp resolve_arg(a) when is_atom(a) do
    if is_module?(a) do
      a.expression()
    else
      {:value, a}
    end
  end

  defp resolve_arg({:path, [], [path]}), do: {:path, path(path)}

  defp resolve_arg({op, _, args}) when op in [:one, :all] do
    %Expression{op: op, args: Enum.map(args, &resolve_arg/1)}
  end

  defp resolve_arg(other), do: other

  defp path(path), do: path |> String.split(".") |> Enum.map(&String.to_atom/1)

  def is_module?(atom) when is_atom(atom), do: to_string(atom) =~ "Elixir"

  defp expression(:not_nil, [arg]), do: %Expression{op: :neq, args: [arg, {:value, nil}]}
  defp expression(:same, args), do: %Expression{op: :eq, args: args}
  defp expression(:member, args), do: %Expression{op: :in, args: args}
  defp expression(:is_true, [arg]), do: %Expression{op: :eq, args: [arg, {:value, true}]}
  defp expression(:is_false, [arg]), do: %Expression{op: :eq, args: [arg, {:value, false}]}
  defp expression(op, args), do: %Expression{op: op, args: args}
end
