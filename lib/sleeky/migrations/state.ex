defmodule Sleeky.Migrations.State do
  @moduledoc """
  Manages a set of schemas during migrations
  """

  alias Sleeky.Migrations.Schema

  @type t :: %__MODULE__{}

  defstruct schemas: %{}

  def new, do: %__MODULE__{}

  def add_schema(state, name) do
    schema = Schema.new(name)
    schemas = Map.put(state.schemas, name, schema)

    %{state | schemas: schemas}
  end

  def remove_schema(state, name) do
    schemas = Map.drop(state.schemas, [name])

    %{state | schemas: schemas}
  end

  def has_schema?(state, name), do: Map.has_key?(state.schemas, name)

  def has?(state, schema, kind, name) do
    case Map.get(state.schemas, schema) do
      nil -> false
      schema -> Schema.has?(schema, kind, name)
    end
  end

  def find(state, schema, kind, name) do
    with_schema(state, schema, fn schema ->
      Schema.find(schema, kind, name)
    end)
  end

  def find!(state, schema, kind, name) do
    with_schema!(state, schema, fn schema ->
      Schema.find!(schema, kind, name)
    end)
  end

  def add!(state, schema, kind, item) do
    with_new_or_existing_schema(state, schema, fn schema ->
      schema = Schema.add!(schema, kind, item)
      schemas = Map.put(state.schemas, schema.name, schema)

      %{state | schemas: schemas}
    end)
  end

  def remove!(state, schema, kind, item) do
    with_schema!(state, schema, fn schema ->
      schema = Schema.remove!(schema, kind, item)
      schemas = Map.put(state.schemas, schema.name, schema)

      %{state | schemas: schemas}
    end)
  end

  def replace!(state, schema, kind, item) do
    with_schema!(state, schema, fn schema ->
      schema = Schema.replace!(schema, kind, item)
      schemas = Map.put(state.schemas, schema.name, schema)

      %{state | schemas: schemas}
    end)
  end

  defp with_schema!(state, schema, fun) do
    case Map.get(state.schemas, schema) do
      nil ->
        schemas = state.schemas |> Map.keys() |> inspect()
        schema = inspect(schema)
        raise "No such schema #{schema} in #{schemas}"

      schema ->
        fun.(schema)
    end
  end

  defp with_new_or_existing_schema(state, schema, fun) do
    case Map.get(state.schemas, schema) do
      nil ->
        state
        |> add_schema(schema)
        |> Map.fetch!(:schemas)
        |> Map.fetch!(schema)
        |> fun.()

      schema ->
        fun.(schema)
    end
  end

  defp with_schema(state, schema, fun) do
    with %Schema{} = schema <- Map.get(state.schemas, schema) do
      fun.(schema)
    end
  end
end
