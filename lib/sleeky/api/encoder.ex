defmodule Sleeky.Api.Encoder do
  @moduledoc """
  A generic json api encoder
  """

  def encode(%Paginator.Page{} = page) do
    entries = encode(page.entries)

    page.metadata
    |> Map.take([:after, :before, :limit, :total_count])
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Enum.into(%{})
    |> Map.put(:items, entries)
  end

  def encode(entity) when is_struct(entity) do
    entity
    |> extract_attributes()
    |> extract_relations(entity)
  end

  def encode(entities) when is_list(entities), do: for(entity <- entities, do: encode(entity))

  defp extract_attributes(entity) do
    attributes = entity.__struct__.attributes()
    names = for attr <- attributes, do: attr.name

    Map.take(entity, names)
  end

  defp extract_relations(data, entity) do
    parents = entity.__struct__.parents()

    Enum.reduce(parents, data, fn rel, acc ->
      case Map.get(entity, rel.name) do
        nil ->
          acc

        %{__struct__: Ecto.Association.NotLoaded} ->
          id = Map.get(entity, rel.column_name)
          value = if not is_nil(id), do: %{id: id}
          Map.put(acc, rel.name, value)

        %{id: _} = value ->
          Map.put(acc, rel.name, encode(value))
      end
    end)
  end
end
