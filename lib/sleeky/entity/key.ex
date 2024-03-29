defmodule Sleeky.Entity.Key do
  @moduledoc false
  alias Sleeky.Entity.Summary

  defstruct [
    :name,
    :fields,
    :index,
    :entity,
    list_function_name: nil,
    aggregate_function_name: nil,
    read_function_name: nil,
    unique: false
  ]

  def new(fields) do
    __MODULE__
    |> struct(fields)
    |> with_summary_entity()
    |> with_name_and_index()
  end

  defp with_summary_entity(key) do
    %{key | entity: Summary.new(key.entity)}
  end

  defp with_name_and_index(key) do
    table = key.entity.table
    columns = key.fields |> Enum.map_join("_", &to_string(&1.column)) |> String.to_atom()
    name = columns
    index = "#{table}_#{columns}_idx"
    %{key | name: name, index: index}
  end
end
