defmodule Sleeky.Context.Helpers do
  @moduledoc false

  alias Sleeky.QueryBuilder

  def maybe_filter(query, model, context) do
    case Map.get(context, :query) do
      nil ->
        query

      filters ->
        builder = QueryBuilder.from_simple_map(model, filters)

        QueryBuilder.build(query, builder)
    end
  end

  def collect_ids(dest, source, fields) do
    Enum.reduce(fields, dest, fn {field, new_key}, acc ->
      case Map.get(source, field) do
        %{id: id} -> Map.put(acc, new_key, id)
        _ -> acc
      end
    end)
  end

  def collect_values(dest, source, fields) do
    Enum.reduce(fields, dest, fn field, acc ->
      case Map.get(source, field) do
        values when is_list(values) -> Map.put(acc, field, values)
        _ -> acc
      end
    end)
  end

  def set_default_values(attrs, defaults) do
    Enum.reduce(defaults, attrs, fn {key, default_value}, acc ->
      Map.put_new(acc, key, default_value)
    end)
  end

  def string_keys(map) do
    for {key, value} <- map, into: %{} do
      {to_string(key), value}
    end
  end
end
