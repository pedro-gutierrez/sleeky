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

  def atoms(l) when is_list(l) do
    Enum.map(l, &atoms/1)
  end

  def atoms(a) when is_binary(a), do: String.to_atom(a)
  def atoms(a) when is_atom(a), do: a

  def strings(l) when is_list(l) do
    Enum.map(l, &strings/1)
  end

  def strings(a) when is_binary(a), do: a
  def strings(a) when is_atom(a), do: to_string(a)

  def as_list(items) when is_list(items), do: items
  def as_list(single), do: [single]

  def join(items) do
    items
    |> strings()
    |> Enum.join("_")
    |> String.to_atom()
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
