defmodule Sleeky.Ast do
  @moduledoc """
  Convenience functions to work with quoted expressions
  """

  @doc """
  Returns a variable of the given name

  This is used when generating code, such as functions, inside macros
  """
  def var(name), do: Macro.var(name, nil)

  @doc """
  Flattens a list of expressions, discarding nil ones

  Useful when used inside unquoting
  """
  def flattened(asts) do
    asts
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Print a quoted expression

  For debugging purposes only
  """
  def print(ast, condition \\ true) do
    if condition do
      ast
      |> Macro.to_string()
      |> Code.format_string!()
      |> IO.puts()
    end

    ast
  end
end
