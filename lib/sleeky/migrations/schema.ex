defmodule Sleeky.Migrations.Schema do
  @moduledoc """
  Keeps tables, constraints and indexes of the same database schema together, during migration parsing and diffing
  """

  @type t :: %__MODULE__{}

  defstruct [:name, tables: %{}, constraints: %{}, indexes: %{}]

  def new(name), do: %__MODULE__{name: name}

  def has?(schema, kind, name) do
    schema
    |> Map.fetch!(kind)
    |> Map.has_key?(name)
  end

  def find(schema, kind, name) do
    schema
    |> Map.fetch!(kind)
    |> Map.get(name)
  end

  def find!(schema, kind, name) do
    schema
    |> Map.fetch!(kind)
    |> Map.fetch!(name)
  end

  def add!(schema, kind, item) do
    if has?(schema, kind, item.name) do
      raise "Cannot add #{inspect(item)} into #{kind} of schema #{schema.name} (already exists)"
    else
      replace!(schema, kind, item)
    end
  end

  def remove!(schema, kind, item) do
    if has?(schema, kind, item.name) do
      items = schema |> Map.fetch!(kind) |> Map.drop([item.name])
      Map.put(schema, kind, items)
    else
      raise "Cannot remove #{inspect(item)} from #{kind} of schema #{schema.name} (does not exist)"
    end
  end

  def replace!(schema, kind, item) do
    items =
      schema
      |> Map.fetch!(kind)
      |> Map.put(item.name, item)

    Map.put(schema, kind, items)
  end
end
