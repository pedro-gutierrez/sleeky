defmodule Sleeky.Context.Generator.Graph do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(context, _) do
    graph = Graph.new()

    graph =
      Enum.reduce(context.models, graph, fn model, g ->
        g
        |> with_model(model)
        |> with_attributes(model)
        |> with_parents(model)
      end)

    [
      graph_function(graph),
      get_shortest_path_function(),
      get_paths_function(),
      diagram_function(context, graph),
      simple_path_function(),
      vertex_function()
    ]
  end

  defp graph_function(graph) do
    quote do
      @graph unquote(Macro.escape(graph))
      def graph, do: @graph
    end
  end

  defp get_shortest_path_function do
    quote do
      def get_shortest_path(model_name, field) do
        case vertex(field) do
          nil ->
            []

          target ->
            @graph
            |> Graph.get_shortest_path({:model, model_name}, target)
            |> simple_path()
        end
      end
    end
  end

  defp get_paths_function do
    quote do
      def get_paths(model_name, field) do
        case vertex(field) do
          nil ->
            []

          target ->
            @graph
            |> Graph.get_paths({:model, model_name}, target)
            |> Enum.map(&simple_path/1)
            |> Enum.sort_by(&length/1)
        end
      end
    end
  end

  defp simple_path_function do
    quote do
      defp simple_path(path) do
        path
        |> Enum.map(fn
          {:model, _} -> nil
          {_, field} -> field
        end)
        |> Enum.reject(&is_nil/1)
      end
    end
  end

  defp vertex_function do
    quote do
      defp vertex(field) do
        target = {:parent, field}

        cond do
          Graph.has_vertex?(@graph, {:parent, field}) ->
            {:parent, field}

          Graph.has_vertex?(@graph, {:attribute, field}) ->
            {:attribute, field}

          true ->
            nil
        end
      end
    end
  end

  defp diagram_function(context, graph) do
    {:ok, dot} = Graph.to_dot(graph)
    name = context.name

    quote do
      @graph_dot unquote(dot)
      def diagram_source, do: @graph_dot

      def diagram do
        File.write!("#{unquote(name)}.dot", @graph_dot)

        command = "sh"

        args = [
          "-c",
          "dot -Tpng #{unquote(name)}.dot > #{unquote(name)}.png; open #{unquote(name)}.png"
        ]

        with {"", 0} <- System.cmd(command, args), do: :ok
      end
    end
  end

  defp with_model(graph, model) do
    Graph.add_vertex(graph, {:model, model.name()})
  end

  defp with_attributes(graph, model) do
    attrs = model.attributes()

    Enum.reduce(attrs, graph, fn attr, g ->
      g
      |> Graph.add_vertex({:attribute, attr.name})
      |> Graph.add_edge({:model, model.name()}, {:attribute, attr.name})
    end)
  end

  defp with_parents(graph, model) do
    rels = model.parents()

    Enum.reduce(rels, graph, fn rel, g ->
      g
      |> Graph.add_vertex({:parent, rel.name})
      |> Graph.add_edge({:model, model.name()}, {:parent, rel.name})
      |> Graph.add_edge({:parent, rel.name}, {:model, rel.target.module.name()})
    end)
  end
end
