defmodule Sleeky.JsonApi.Encoder do
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

  def encode(model) when is_struct(model) do
    model
    |> extract_attributes()
    |> extract_relations(model)
  end

  def encode(models) when is_list(models), do: for(model <- models, do: encode(model))

  defp extract_attributes(model) do
    attributes = model.__struct__.attributes()
    names = for attr <- attributes, do: attr.name

    Map.take(model, names)
  end

  defp extract_relations(data, model) do
    parents = model.__struct__.parents()

    Enum.reduce(parents, data, fn rel, acc ->
      case Map.get(model, rel.name) do
        nil ->
          acc

        %{__struct__: Ecto.Association.NotLoaded} ->
          id = Map.get(model, rel.column_name)
          Map.put(acc, rel.name, %{id: id})

        %{id: _} = value ->
          Map.put(acc, rel.name, encode(value))
      end
    end)
  end
end
