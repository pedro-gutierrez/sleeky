defmodule Bee.Database.State do
  @moduledoc false

  @type t :: %__MODULE__{}

  defstruct tables: %{}, foreign_keys: %{}

  def new, do: %__MODULE__{}

  def has?(state, key, name) do
    state
    |> Map.fetch!(key)
    |> Map.has_key?(name)
  end

  def add_new!(item, key, state) do
    items = Map.fetch!(state, key)

    if Map.has_key?(items, item.name) do
      keys = Map.keys(items)

      raise "Cannot add into #{inspect(key)}. Item #{inspect(item.name)} already exists in state: #{inspect(keys)}"
    end

    items = Map.put(items, item.name, item)
    Map.put(state, key, items)
  end

  def remove_existing!(item, key, state) do
    items = Map.fetch!(state, key)

    if !Map.has_key?(items, item.name) do
      keys = Map.keys(items)

      raise "Cannot remove from #{inspect(key)}. Item #{inspect(item.name)} does not exist in state: #{inspect(keys)}"
    end

    items = Map.drop(items, [item.name])
    Map.put(state, key, items)
  end
end
