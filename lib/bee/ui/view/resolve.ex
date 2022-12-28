defmodule Bee.UI.View.Resolve do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def render(args \\ %{}) do
        resolved = resolve(args)
        HTMLBuilder.encode!(resolved)
      end

      def definition, do: @definition

      def resolve(args \\ %{}) do
        with {node, attrs, children} when is_list(children) <- resolve(@definition, args) do
          {node, attrs, List.flatten(children)}
        end
      end

      def resolve_slots(slots, args) do
        resolve_slots(slots, args, fn
          {name, _, value} -> {name, value}
          {name, value} -> {name, value}
        end)
      end

      def resolve_slots(slots, args, fun) do
        slots
        |> resolve(args)
        |> case do
          args when is_list(args) -> args
          arg -> [arg]
        end
        |> Enum.map(fun)
        |> Enum.into(%{})
      end

      def resolve({:slot, name, [child]}, args) when is_atom(name) do
        case slot!(name, args) do
          items when is_list(items) ->
            Enum.map(items, fn item ->
              item = Enum.into(item, %{})
              resolve(child, item)
            end)
        end
      end

      def resolve({:slot, [], [name]}, args) when is_atom(name) do
        resolve({:slot, name}, args)
      end

      def resolve({:slot, name}, args) when is_atom(name) do
        name
        |> slot!(args)
        |> resolve(args)
      end

      def resolve({:loop, [], children} = directive, args) do
        entity = entity!(args)
        resolve({:loop, [entity.plural(), :items], children}, args)
      end

      def resolve({:loop, path, children}, args) do
        path = Enum.map_join(path, ".", &to_string/1)

        {:template,
         [
           "x-for": "item in $store.#{path}",
           ":key": "item.id"
         ], resolve(children, args)}
      end

      def resolve({:entity, entity, children}, args) do
        items = entity.plural()
        args = Map.put(args, :__entity__, entity)

        {:div,
         [
           "x-show": "$store.router.items == '#{items}'",
           "x-init": "$store.#{items}.list()"
         ], resolve(children, args)}
      end

      def resolve({:view, view}, args) do
        Code.ensure_compiled!(view)
        view.resolve(args)
      end

      def resolve({:view, [], [view]}, args) do
        Code.ensure_compiled!(view)
        view.resolve(args)
      end

      def resolve({:view, view, slots}, args) do
        Code.ensure_compiled!(view)
        slots = resolve_slots(slots, args)
        args = args |> Map.take([:__entity__]) |> Map.merge(slots)
        view.resolve(args)
      end

      def resolve({node, attrs, children}, args) do
        {node, attrs |> resolve(args) |> sanitize_attrs(), resolve(children, args)}
      end

      def resolve({node, children}, args) when is_list(children) do
        {node, [], resolve(children, args)}
      end

      def resolve(nodes, args) when is_list(nodes) do
        for n <- nodes, do: resolve(n, args)
      end

      def resolve({name, value}, args) do
        {name, resolve(value, args)}
      end

      def resolve(other, _args) when is_binary(other) or is_number(other) or is_atom(other) do
        other
      end

      def resolve(other, _args) do
        raise """
        Don't know how to resolve markup:

        #{inspect(other)}

        in view #{__MODULE__}
        """
      end

      defp entity!(args) do
        entity = Map.get(args, :__entity__)

        unless entity do
          raise "View #{inspect(__MODULE__)} is trying to resolve the current entity but not value was provided:
            #{inspect(args)}"
        end

        entity
      end

      defp slot!(name, args) do
        with nil <- Map.get(args, name) do
          raise "View #{inspect(__MODULE__)} is trying to resolve slot #{inspect(name)} but no value was provided:
            #{inspect(args)}"
        end
      end

      defp sanitize_attrs(attrs) do
        for {name, value} <- attrs, do: {name, sanitize_attr(value)}
      end

      defp sanitize_attr([value]), do: sanitize_attr(value)
      defp sanitize_attr(value) when is_binary(value) or is_boolean(value), do: value
      defp sanitize_attr(value) when is_atom(value), do: to_string(value)
    end
  end
end
