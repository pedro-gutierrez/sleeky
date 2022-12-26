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

  def module(parts) when is_list(parts) do
    parts
    |> Enum.map(&Inflex.camelize/1)
    |> Module.concat()
  end

  def module_parts(mod) do
    mod
    |> Module.split()
    |> Enum.map(&snake/1)
  end

  def module(prefix, suffix) do
    prefix = Inflex.camelize(prefix)
    suffix = Inflex.camelize(suffix)

    Module.concat(prefix, suffix)
  end

  def flatten(items) do
    items
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  def function_name(prefix, suffix) when is_list(suffix) do
    suffix = suffix |> strings() |> Enum.join("_and_")

    join(prefix, suffix)
  end

  def function_name(prefix, suffix) do
    join(prefix, suffix)
  end

  def atoms(l) when is_list(l), do: Enum.map(l, &atoms/1)
  def atoms(a) when is_binary(a), do: String.to_atom(a)
  def atoms(a) when is_atom(a), do: a

  def strings(l) when is_list(l), do: Enum.map(l, &strings/1)
  def strings(a) when is_binary(a), do: a
  def strings(a) when is_atom(a), do: to_string(a)

  def as_list(items) when is_list(items), do: items
  def as_list(single), do: [single]

  def tokenize(str, separator \\ ".")

  def tokenize(str, separator) when is_binary(str) do
    str |> String.split(separator) |> tokenize()
  end

  def tokenize(other, _separator), do: atoms(other)

  def join(items) do
    items
    |> strings()
    |> Enum.join("_")
    |> String.to_atom()
  end

  def join(prefix, suffix) do
    join([prefix, suffix])
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

  def label(name) do
    name |> to_string() |> String.replace("_", " ") |> String.capitalize()
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

  def snake(value), do: value |> Macro.underscore() |> String.to_atom()
end
