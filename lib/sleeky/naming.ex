defmodule Sleeky.Naming do
  @moduledoc """
  Naming conventions
  """

  @doc false
  def name(model) do
    model
    |> last_module()
    |> Macro.underscore()
    |> String.to_atom()
  end

  @doc false
  def plural(model) do
    model
    |> last_module()
    |> to_string()
    |> Macro.underscore()
    |> Inflex.pluralize()
    |> String.to_atom()
  end

  @doc false
  def table_name(model) do
    plural(model)
  end

  @doc false
  def column_name(model, alias \\ nil) do
    name =
      if alias do
        alias
      else
        name(model)
      end

    String.to_atom("#{name}_id")
  end

  defp last_module(name) do
    name
    |> Module.split()
    |> List.last()
  end

  @doc false
  def module(domain, name) do
    name = name |> to_string() |> Macro.camelize()
    Module.concat(domain, name)
  end

  @doc false
  def domain(model) do
    model
    |> Module.split()
    |> Enum.reverse()
    |> tl()
    |> Enum.reverse()
    |> Module.concat()
  end

  @doc false
  def repo(domain) do
    domain
    |> Module.split()
    |> Enum.drop(-1)
    |> Kernel.++([Repo])
    |> Module.concat()
  end

  @doc false
  def indexed(items, key \\ :name) do
    Enum.reduce(items, %{}, fn item, index ->
      index_key = Map.get(item, key)
      Map.put(index, index_key, item)
    end)
  end

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
