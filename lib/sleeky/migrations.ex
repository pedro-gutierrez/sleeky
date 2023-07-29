defmodule Sleeky.Migrations do
  @moduledoc false
  alias Sleeky.Migrations.Migration
  alias Sleeky.Database.Constraint
  alias Sleeky.Database.Index
  alias Sleeky.Database.State
  alias Sleeky.Database.Table

  def existing(dir) do
    Path.join([dir, "*_sleeky_*.exs"])
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(&File.read!(&1))
    |> Enum.map(&Code.string_to_quoted!(&1))
    |> Enum.map(&Migration.decode/1)
    |> Enum.reject(& &1.skip)
  end

  def missing(migrations, schema) do
    new_state = state_from_schema(schema)
    old_state = state_from_migrations(migrations)
    next_version = next_version(migrations)

    Migration.diff(old_state, new_state, version: next_version)
  end

  defp state_from_migrations(migrations) do
    migrations
    |> Enum.reject(& &1.skip)
    |> Enum.reduce(State.new(), &Migration.aggregate/2)
  end

  defp state_from_schema(schema) do
    state =
      schema.entities
      |> Enum.reject(& &1.virtual?)
      |> Enum.reduce(State.new(), &state_with_entity/2)

    Enum.reduce(schema.enums, state, &state_with_enum/2)
  end

  defp state_with_entity(entity, state) do
    state =
      entity
      |> Table.from_entity()
      |> State.add!(:tables, state)

    state =
      entity
      |> Constraint.all_from_entity()
      |> Enum.reduce(state, &State.add!(&1, :constraints, &2))

    entity
    |> Index.all_from_entity()
    |> Enum.reduce(state, &State.add!(&1, :indices, &2))
  end

  defp state_with_enum(enum, state) do
    State.add!(enum, :enums, state)
  end

  defp next_version([]), do: 1

  defp next_version(migrations) do
    List.last(migrations).version + 1
  end
end
