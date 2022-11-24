defmodule Bee.Migrations.State do
  @moduledoc false
  alias Bee.Migrations.Migration
  alias Bee.Migrations.Table

  defstruct tables: %{}

  def table?(state, name) do
    Map.has_key?(state.tables, name)
  end

  def from_migrations(migrations) do
    migrations
    |> Enum.reject(& &1.skip)
    |> Enum.reduce(%__MODULE__{}, &Migration.into/2)
  end

  def from_schema(schema) do
    schema.entities
    |> Enum.reject(& &1.virtual?)
    |> Enum.reduce(%__MODULE__{}, &with_entity/2)
  end

  defp with_entity(entity, state) do
    entity
    |> Table.from_entity()
    |> add_to(:tables, state)
  end

  defp add_to(item, key, state) do
    items =
      state
      |> Map.get(key, %{})
      |> Map.put(item.name, item)

    Map.put(state, key, items)
  end
end
