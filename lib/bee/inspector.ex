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

  def module({:__aliases__, _, mod}) do
    Module.concat(mod)
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

  def var(name) when is_atom(name), do: Macro.var(name, nil)
  def var(other), do: other |> Keyword.fetch!(:name) |> var()

  def vars(names), do: Enum.map(names, &var(&1))

  def columns(items) do
    Enum.map(items, & &1.column)
  end

  def indexed(items, key \\ :name) do
    Enum.reduce(items, %{}, fn item, index ->
      index_key = Map.get(item, key)
      Map.put(index, index_key, item)
    end)
  end
end
