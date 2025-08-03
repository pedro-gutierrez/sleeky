defmodule Sleeky.Migrations do
  @moduledoc false
  alias Sleeky.Migrations.Migration
  alias Sleeky.Migrations.Constraint
  alias Sleeky.Migrations.Index
  alias Sleeky.Migrations.State
  alias Sleeky.Migrations.Table

  def existing(dir) do
    Path.join([dir, "*_sleeky_*.exs"])
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(&File.read!(&1))
  end

  def missing(existing, contexts) do
    existing =
      existing
      |> Enum.map(&Code.string_to_quoted!(&1))
      |> Enum.map(&Migration.decode/1)
      |> Enum.reject(& &1.skip)

    new_state = state_from_contexts(contexts)
    old_state = state_from_migrations(existing)
    next_version = next_version(existing)

    Migration.diff(old_state, new_state, version: next_version)
  end

  defp state_from_migrations(migrations) do
    migrations
    |> Enum.reject(& &1.skip)
    |> Enum.reduce(State.new(), &Migration.aggregate/2)
  end

  defp state_from_contexts(contexts) do
    state = Enum.reduce(contexts, State.new(), &state_with_schema/2)

    contexts
    |> Enum.flat_map(& &1.entities())
    |> Enum.reject(& &1.virtual?())
    |> Enum.reduce(state, &state_with_entity/2)
  end

  defp state_with_schema(context, state) do
    State.add_schema(state, context.name())
  end

  defp state_with_entity(entity, state) do
    state
    |> state_with_table(entity)
    |> state_with_constraints(entity)
    |> state_with_indexes(entity)
  end

  defp state_with_table(state, entity) do
    table = Table.from_entity(entity)
    State.add!(state, table.prefix, :tables, table)
  end

  defp state_with_constraints(state, entity) do
    entity.parents()
    |> Enum.map(&Constraint.from_relation/1)
    |> Enum.reduce(state, fn constraint, state ->
      State.add!(state, constraint.prefix, :constraints, constraint)
    end)
  end

  defp state_with_indexes(state, entity) do
    entity.keys()
    |> Enum.map(&Index.from_key/1)
    |> Enum.reduce(state, fn index, state ->
      State.add!(state, index.prefix, :indexes, index)
    end)
  end

  defp next_version([]), do: 1
  defp next_version(migrations), do: List.last(migrations).version + 1
end
