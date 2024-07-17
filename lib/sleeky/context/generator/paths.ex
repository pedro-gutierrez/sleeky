defmodule Sleeky.Context.Generator.Paths do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(context, _) do
    models = context.models

    hierarchies = for model <- models, into: %{}, do: {model.name(), hierarchy(model)}

    ancestors =
      for {model, hierarchy} <- hierarchies,
          into: %{},
          do: {model, ancestors(hierarchy)}

    paths =
      for {model, hierarchy} <- hierarchies,
          into: %{},
          do: {model, ancestors_paths(hierarchy, Map.fetch!(ancestors, model))}

    [
      paths(paths),
      default_paths(),
      attributes_shortest_path(models),
      parents_shortest_path(models),
      ancestors_shortest_path(paths),
      default_shortest_path()
    ]
  end

  defp paths(paths) do
    for {model, ancestors} <- paths, {ancestor, ancestor_paths} <- ancestors do
      quote do
        def paths(unquote(model), unquote(ancestor)), do: unquote(ancestor_paths)
      end
    end
  end

  defp default_paths do
    quote do
      def paths(_, _), do: []
    end
  end

  defp attributes_shortest_path(models) do
    for model <- models, attribute <- model.attributes() do
      quote do
        def shortest_path(unquote(model.name()), unquote(attribute.name)),
          do: [unquote(attribute.name)]
      end
    end
  end

  defp parents_shortest_path(models) do
    for model <- models, rel <- model.parents() do
      quote do
        def shortest_path(unquote(model.name()), unquote(rel.column_name)),
          do: [unquote(rel.column_name)]
      end
    end
  end

  defp ancestors_shortest_path(paths) do
    for {model, ancestors} <- paths, {ancestor, ancestor_paths} <- ancestors do
      shortest_path = List.first(ancestor_paths)

      quote do
        def shortest_path(unquote(model), unquote(ancestor)), do: unquote(shortest_path)
      end
    end
  end

  defp default_shortest_path do
    quote do
      def shortest_path(_, _), do: []
    end
  end

  defp hierarchy(model) do
    model.parents()
    |> Enum.flat_map(fn p ->
      [{p.name, hierarchy(p.target.module)}, {p.column_name, %{}}]
    end)
    |> Enum.into(%{})
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
