defmodule Bee.Inspector do
  def print(ast, condition \\ true) do
    if condition do
      ast
      |> Macro.to_string()
      |> Code.format_string!()
      |> IO.puts()
    end

    ast
  end

  def flatten(items) do
    items
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  def name(entity) do
    entity
    |> Module.split()
    |> List.last()
    |> to_string()
    |> Inflex.underscore()
    |> String.to_atom()
  end

  def plural(name) do
    name
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> String.downcase()
    |> Inflex.pluralize()
    |> String.to_atom()
  end

  def context(module) do
    module |> Module.split() |> Enum.drop(-1) |> Module.concat()
  end

  def names(items) do
    Enum.map(items, & &1.name)
  end

  def columns(items) do
    Enum.map(items, & &1.column)
  end
end
