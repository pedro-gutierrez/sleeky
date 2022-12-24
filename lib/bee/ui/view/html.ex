defmodule Bee.UI.View.Render do
  @moduledoc false

  import Bee.Inspector

  def ast(view) do
    flatten([
      content_function(view),
      render_function(),
      resolve_slots_helpers(),
      resolve_function(),
      resolve_slot_function(),
      resolve_repeat_function(),
      resolve_entity_function(),
      resolve_view_with_arguments_function(),
      resolve_view_without_arguments_function(),
      resolve_children_function(),
      resolve_node_with_attributes_function(),
      resolve_node_without_attributes_function(),
      resolve_nodes_function(),
      resolve_empty_content_function(),
      resolve_literal_function(),
      resolve_field_function(),
      resolve_node_with_single_child(),
      resolve_void_node(),
      resolve_catch_all_function()
    ])
  end

  defp render_function do
    quote do
      def render(args \\ %{}) do
        args |> resolve() |> HTMLBuilder.encode!()
      end
    end
  end

  defp content_function(view) do
    content = Module.get_attribute(view, :content)

    quote do
      def content do
        unquote(Macro.escape(content))
      end
    end
  end

  defp resolve_function do
    quote do
      def resolve(args \\ %{}) do
        content() |> resolve(args)
      end
    end
  end

  defp resolve_slots_helpers do
    [
      quote do
        defp resolve_slots(slots, args) do
          resolve_slots(slots, args, fn {name, _, value} -> {name, value} end)
        end
      end,
      quote do
        defp resolve_slots(slots, args, fun) do
          slots
          |> resolve(args)
          |> case do
            args when is_list(args) -> args
            arg -> [arg]
          end
          |> Enum.map(fun)
          |> Enum.into(%{})
        end
      end
    ]
  end

  defp resolve_slot_function do
    quote do
      def resolve({:slot, _, [name]}, args) do
        case Map.get(args, name) do
          nil ->
            raise "View #{inspect(__MODULE__)} is trying to render slot #{inspect(name)} but no value was provided in:
              #{inspect(args)}"

          value ->
            resolve(value, args)
        end
      end
    end
  end

  defp resolve_repeat_function do
    quote do
      def resolve({:repeat, _, [{:__aliases__, _, view}, [do: slots]]} = directive, args) do
        view = Module.concat(view)
        entity = Map.get(args, :__entity__)

        unless entity do
          raise "View #{inspect(__MODULE__)} is trying to resolve directive\n#{inspect(directive, pretty: true)}\nbut not entity vas provided in: #{inspect(args)}"
        end

        slots =
          resolve_slots(slots, args, fn {name, _, path} ->
            path = Enum.map_join(path, ".", &to_string/1)
            {name, {:span, ["x-text": "#{entity.name()}.#{path}"]}}
          end)

        {:template,
         [
           "x-for": "#{entity.name()} in $store.#{entity.plural()}.all",
           ":key": "#{entity.name()}.id"
         ],
         [
           view.resolve(slots)
         ]}
      end
    end
  end

  defp resolve_entity_function do
    quote do
      def resolve({:entity, _, [{:__aliases__, _, entity}, children]}, args) do
        entity = Module.concat(entity)
        args = Map.put(args, :__entity__, entity)

        {:div, ["x-data": true, "x-init": "$store.#{entity.plural()}.list()"],
         resolve(children, args)}
      end
    end
  end

  defp resolve_view_with_arguments_function do
    quote do
      def resolve({:view, _, [{:__aliases__, _, view}, [do: slots]]}, args) do
        view = Module.concat(view)
        slots = resolve_slots(slots, args)
        args = Map.merge(args, slots)
        view.resolve(args)
      end
    end
  end

  defp resolve_view_without_arguments_function do
    quote do
      def resolve({:view, _, [{:__aliases__, _, view}]}, args) do
        view = Module.concat(view)
        view.resolve(args)
      end
    end
  end

  defp resolve_node_with_attributes_function do
    quote do
      def resolve({node, _, [attrs, children]}, args) when is_list(children) do
        {node, attrs, resolve(children, args)}
      end
    end
  end

  defp resolve_node_without_attributes_function do
    [
      quote do
        def resolve({node, _, [do: children]}, args) do
          {node, [], resolve(children, args)}
        end
      end,
      quote do
        def resolve({node, _, [[do: children]]}, args) do
          {node, [], resolve(children, args)}
        end
      end,
      quote do
        def resolve({node, _, [children]} = block, args) when is_list(children) do
          if Keyword.keyword?(children) do
            {node, children}
          else
            {node, [], resolve(children, args)}
          end
        end
      end,
      quote do
        def resolve({node, [line: _], children} = block, args) when is_list(children) do
          {node, [], resolve(children, args)}
        end
      end
    ]
  end

  defp resolve_children_function do
    [
      quote do
        def resolve({:__block__, _, children}, args), do: resolve(children, args)
      end,
      quote do
        def resolve([[do: children]], args), do: resolve(children, args)
      end,
      quote do
        def resolve([do: children], args), do: resolve(children, args)
      end
    ]
  end

  defp resolve_nodes_function do
    quote do
      def resolve(nodes, args) when is_list(nodes) do
        for n <- nodes, do: resolve(n, args)
      end
    end
  end

  def resolve_node_with_single_child() do
    quote do
      def resolve({_, _, _} = other, _args) do
        other
      end
    end
  end

  def resolve_void_node() do
    quote do
      def resolve({_, _} = other, _args) do
        other
      end
    end
  end

  defp resolve_empty_content_function do
    quote do
      def resolve({:__block__, _, _}, _args) do
        []
      end
    end
  end

  defp resolve_literal_function do
    quote do
      def resolve(other, _args) when is_binary(other) or is_number(other) do
        other
      end
    end
  end

  defp resolve_field_function do
    quote do
      def resolve(field, _args) when is_atom(field) do
        field
      end
    end
  end

  defp resolve_catch_all_function do
    quote do
      def resolve(other, args) do
        raise """
        Don't know how to resolve markup:

          #{inspect(other)}

        in view #{__MODULE__}
        """
      end
    end
  end
end
