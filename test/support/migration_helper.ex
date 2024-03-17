defmodule MigrationHelper do
  @moduledoc """
  Some utility functions for migration related tests
  """

  alias Sleeky.Migrations
  alias Sleeky.Migrations.Migration

  import ExUnit.Assertions

  @doc false
  def generate_migrations(existing \\ []) do
    contexts = :sleeky |> Application.fetch_env!(Sleeky) |> Keyword.fetch!(:contexts)

    existing
    |> Migrations.missing(contexts)
    |> Migration.encode()
    |> Migration.format()
    |> Enum.join("")
  end

  @doc false
  def assert_migrations(migrations, statement) when is_binary(statement) do
    assert_migrations(migrations, [statement])
  end

  @doc false
  def assert_migrations(migrations, statements) when is_list(statements) do
    assert migrations =~ Enum.join(statements, "\n      ")

    migrations
  end

  @doc false
  def refute_migrations(migrations, statements) do
    refute migrations =~ Enum.join(statements, "\n      ")

    migrations
  end
end
