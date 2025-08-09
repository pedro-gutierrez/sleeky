defmodule Sleeky.Scope do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Scope.Dsl,
    parser: Sleeky.Scope.Parser,
    generators: [
      Sleeky.Scope.Generator.Metadata,
      Sleeky.Scope.Generator.Allowed
    ]

  alias Sleeky.Evaluate
  alias Sleeky.Compare

  defmodule Expression do
    @moduledoc false
    defstruct [:op, :args]
  end

  defstruct [:name, :debug, :expression]

  def allowed?(scope, context), do: allowed?(scope, scope.expression(), context)

  defp allowed?(_scope, %Expression{op: :one} = expr, context) do
    Enum.reduce_while(expr.args, nil, fn {:scope, scope}, _ ->
      if allowed?(scope, context) do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end

  defp allowed?(_scope, %Expression{op: :all} = expr, context) do
    Enum.reduce_while(expr.args, nil, fn {:scope, scope}, _ ->
      if allowed?(scope, context) do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  defp allowed?(scope, %Expression{} = expr, context) do
    values = Enum.map(expr.args, &Evaluate.evaluate(context, &1))

    result = Compare.compare(expr.op, values)

    if scope.debug?() do
      IO.inspect(
        scope: scope,
        args: expr.args,
        values: values,
        op: expr.op,
        context: context,
        result: result
      )
    end

    result
  end
end
