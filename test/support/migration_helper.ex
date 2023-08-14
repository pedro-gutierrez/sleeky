defmodule MigrationHelper do
  @moduledoc """
  Some utility functions for migration related tests
  """

  alias Sleeky.Migrations
  alias Sleeky.Migrations.Migration

  def generate_migration(existing \\ [], schema \\ TestApp.Schema) do
    existing
    |> Migrations.missing(schema)
    |> Migration.encode()
    |> Migration.format()
    |> Enum.join("")
  end
end
