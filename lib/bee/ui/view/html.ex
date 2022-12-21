defmodule Bee.UI.View.Render do
  @moduledoc false

  import Bee.Inspector

  def ast(view) do
    flatten([
      content_function(view),
      render_function(),
      resolve_function(),
      resolve_slot_function(),
      resolve_view_with_arguments_function(),
      resolve_view_without_arguments_function(),
      resolve_children_function(),
      resolve_node_with_attributes_function(),
      resolve_node_without_attributes_function(),
      resolve_nodes_function(),
      resolve_empty_content_function(),
      resolve_literal_function(),
      resolve_node_with_single_child(),
      resolve_void_node(),
      resolve_catch_all_function(),
      resolve_args_function(),
      resolve_arg_function()
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

  defp resolve_slot_function do
    quote do
      def resolve({:slot, _, [name]}, args) do
        case Map.get(args, name) do
          nil ->
            raise """
            View
                #{inspect(__MODULE__)}
            is trying to render slot
                #{inspect(name)}
            but no value was provided in:
                #{inspect(args)}
            """

          value ->
            resolve(value, %{})
        end
      end
    end
  end

  defp resolve_view_with_arguments_function do
    quote do
      def resolve({:view, _, [{:__aliases__, _, view}, [do: args]]}, _args) do
        view = Module.concat(view)
        args = resolve_args(args)
        view.resolve(args)
      end
    end
  end

  defp resolve_view_without_arguments_function do
    quote do
      def resolve({:view, _, [{:__aliases__, _, view}]}, _args) do
        view = Module.concat(view)
        view.resolve(%{})
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

  defp resolve_arg_function do
    quote do
      defp resolve_arg({name, _, content}), do: {name, resolve(content, %{})}
    end
  end

  defp resolve_args_function do
    [
      quote do
        defp resolve_args({:__block__, _, args}) when is_list(args) do
          for arg <- args, into: %{}, do: resolve_arg(arg)
        end
      end,
      quote do
        defp resolve_args(args) when is_list(args) do
          for arg <- args, into: %{}, do: resolve_arg(arg)
        end
      end,
      quote do
        defp resolve_args({name, _, content} = arg), do: resolve_args([arg])
      end
    ]
  end
end
