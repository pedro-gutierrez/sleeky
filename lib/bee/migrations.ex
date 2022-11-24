defmodule Bee.Migrations do
  @moduledoc false
  alias Bee.Migrations.Migration
  alias Bee.Migrations.State

  def existing(dir) do
    Path.join([dir, "*_bee_*.exs"])
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(&File.read!(&1))
    |> Enum.map(&Code.string_to_quoted!(&1))
    |> Enum.map(&Migration.decode/1)
    |> Enum.reject(& &1.skip)
  end

  def missing(migrations, schema) do
    new = State.from_schema(schema)
    existing = State.from_migrations(migrations)
    next_version = next_version(migrations)

    Migration.diff(existing, new, version: next_version)
  end

  defp next_version([]), do: 1

  defp next_version(migrations) do
    List.last(migrations).version + 1
  end
end
