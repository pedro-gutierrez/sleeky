defmodule Sleeky.Schema.Generator.NearestPath do
  @moduledoc false
  @behaviour Diesel.Generator
  import Sleeky.Schema.Definition

  @impl true
  def generate(_schema, definition) do
    entities = entities(definition)

    hierarchies = for entity <- entities, into: %{}, do: {entity, hierarchy(entity)}

    ancestors =
      for {entity, hierarchy} <- hierarchies,
          into: %{},
          do: {entity, ancestors(hierarchy)}

    paths =
      for {entity, hierarchy} <- hierarchies,
          into: %{},
          do: {entity, ancestors_paths(hierarchy, Map.fetch!(ancestors, entity))}

    [
      paths(paths),
      default_paths(),
      shortest_path(paths),
      default_shortest_path()
    ]
  end

  defp paths(paths) do
    for {entity, ancestors} <- paths, {ancestor, ancestor_paths} <- ancestors do
      quote do
        def paths(unquote(entity), unquote(ancestor)), do: unquote(ancestor_paths)
      end
    end
  end

  defp default_paths do
    quote do
      def paths(_, _), do: []
    end
  end

  defp shortest_path(paths) do
    for {entity, ancestors} <- paths, {ancestor, ancestor_paths} <- ancestors do
      shortest_path = List.first(ancestor_paths)

      quote do
        def shortest_path(unquote(entity), unquote(ancestor)), do: unquote(shortest_path)
      end
    end
  end

  defp default_shortest_path do
    quote do
      def shortest_path(_, _), do: []
    end
  end

  defp hierarchy(entity) do
    for p <- entity.parents(), into: %{} do
      {p.name, hierarchy(p.target.module)}
    end
  end

  defp ancestors(hierarchy) do
    for {parent, grand_parents} <- hierarchy, into: [] do
      [parent] ++ ancestors(grand_parents)
    end
    |> List.flatten()
    |> Enum.uniq()
  end

  defp ancestors_paths(hierarchy, ancestors) do
    paths =
      hierarchy_paths(hierarchy, [])
      |> Enum.map(&Tuple.to_list/1)

    for ancestor <- ancestors, into: %{}, do: {ancestor, ancestor_paths(ancestor, paths)}
  end

  defp hierarchy_paths(hierarchy, []) when map_size(hierarchy) == 0 do
    []
  end

  defp hierarchy_paths(hierarchy, context) when map_size(hierarchy) == 0 do
    [List.to_tuple(context)]
  end

  defp hierarchy_paths(hierarchy, context) do
    Enum.flat_map(hierarchy, fn {parent, ancestors} ->
      hierarchy_paths(ancestors, context ++ [parent])
    end)
  end

  defp ancestor_paths(ancestor, paths) do
    paths
    |> Enum.filter(&Enum.member?(&1, ancestor))
    |> Enum.map(fn path ->
      index = Enum.find_index(path, fn step -> ancestor == step end)
      {path, _} = Enum.split(path, index + 1)
      path
    end)
    |> Enum.uniq()
    |> Enum.sort_by(&length/1)
  end
end
