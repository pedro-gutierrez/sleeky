defmodule Bee.Migrations.CreateTable do
  @moduledoc false
  alias Bee.Migrations.Migration
  alias Bee.Migrations.State

  defstruct [:table]

  def new(table) do
    %__MODULE__{table: table}
  end

  def from_file(step, migration) do
    IO.inspect(parsing: step)
    migration
  end

  def diff(old, new, migration) do
    Enum.reduce(new.tables, migration, fn {_, table}, migration ->
      if !State.table?(old, table.name) do
        table
        |> new()
        |> Migration.with_step(migration)
      else
        migration
      end
    end)
  end

  def encode(_migration) do
    []
  end
end
