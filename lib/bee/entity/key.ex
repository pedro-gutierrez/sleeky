defmodule Bee.Entity.Key do
  @moduledoc false
  alias Bee.Entity.Summary

  import Bee.Inspector

  defstruct [
    :name,
    :fields,
    :index,
    :entity,
    list_function_name: nil,
    unique: false
  ]

  def new(fields) do
    __MODULE__
    |> struct(fields)
    |> with_summary_entity()
    |> with_name_and_index()
    |> with_list_function_name()
  end

  defp with_summary_entity(key) do
    %{key | entity: Summary.new(key.entity)}
  end

  defp with_name_and_index(key) do
    table = key.entity.table
    columns = key.fields |> Enum.map_join("_", &to_string(&1.column)) |> String.to_atom()
    name = columns
    index = "#{table}_#{columns}_key"
    %{key | name: name, index: index}
  end

  defp with_list_function_name(key) do
    if key.unique do
      key
    else
      fields = names(key.fields)
      function_name = join([:list, key.entity.plural(), :by] ++ fields)
      %{key | list_function_name: function_name}
    end
  end
end
