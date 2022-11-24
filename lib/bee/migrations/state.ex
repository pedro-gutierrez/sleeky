defmodule Bee.Migrations.State do
  @moduledoc false
  alias Bee.Migrations.Migration
  alias Bee.Migrations.Table

  @type t :: %__MODULE__{}

  defstruct tables: %{}

  def table?(state, name) do
    Map.has_key?(state.tables, name)
  end

  def from_migrations(migrations) do
    migrations
    |> Enum.reject(& &1.skip)
    |> Enum.reduce(%__MODULE__{}, &Migration.aggregate/2)
  end

  def from_schema(schema) do
    schema.entities
    |> Enum.reject(& &1.virtual?)
    |> Enum.reduce(%__MODULE__{}, &with_entity/2)
  end

  defp with_entity(entity, state) do
    entity
    |> Table.from_entity()
    |> add_new!(:tables, state)
  end

  def add_new!(item, key, state) do
    items = Map.fetch!(state, key)

    if Map.has_key?(items, item.name) do
      raise "Item #{inspect(item)} already exists in state: #{Map.keys(items)}"
    end

    items = Map.put(items, item.name, item)
    Map.put(state, key, items)
  end
end
