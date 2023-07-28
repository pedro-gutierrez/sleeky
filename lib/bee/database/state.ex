defmodule Sleeki.Database.State do
  @moduledoc false

  @type t :: %__MODULE__{}

  defstruct tables: %{}, constraints: %{}, indices: %{}, enums: %{}

  def new, do: %__MODULE__{}

  def has?(state, key, name) do
    state
    |> Map.fetch!(key)
    |> Map.has_key?(name)
  end

  def find!(name, key, state) do
    state
    |> Map.fetch!(key)
    |> Map.fetch!(name)
  end

  def add!(item, key, state) do
    items = Map.fetch!(state, key)

    if Map.has_key?(items, item.name) do
      keys = Map.keys(items)

      raise """
      Cannot add into #{inspect(key)}.

      Item #{inspect(item.name)} already exists in state: #{inspect(keys)}
      """
    end

    items = Map.put(items, item.name, item)
    Map.put(state, key, items)
  end

  def remove!(item, key, state) do
    items = Map.fetch!(state, key)

    if !Map.has_key?(items, item.name) do
      keys = Map.keys(items)

      raise """
      Cannot remove from #{inspect(key)}.

      Item #{inspect(item.name)} does not exist in state: #{inspect(keys)}
      """
    end

    items = Map.drop(items, [item.name])
    Map.put(state, key, items)
  end

  def replace!(item, key, state) do
    items =
      state
      |> Map.fetch!(key)
      |> Map.put(item.name, item)

    Map.put(state, key, items)
  end
end
