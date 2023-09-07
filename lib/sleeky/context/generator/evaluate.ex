defmodule Sleeky.Context.Generator.Evaluate do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_schema, _definition) do
    quote do
      def evaluate(nil, _), do: nil
      def evaluate(value, []), do: value

      def evaluate(_, %{app: app, env: env, key: key}) do
        app |> Application.fetch_env!(env) |> Keyword.fetch!(key)
      end

      def evaluate(_, {:literal, v}), do: v
      def evaluate(%{__struct__: _} = context, [:**]), do: context

      def evaluate(%{__struct__: entity} = context, [field]) when is_atom(field) do
        case entity.field_spec(field) do
          {:error, :unknown_field} ->
            if entity.name() == field do
              context
            else
              Map.get(context, field)
            end

          {:ok, _kind, _column} ->
            Map.fetch!(context, field)

          {:ok, :child, _, _} ->
            context
            |> entity.relation(field)
            |> Enum.reject(&is_nil/1)

          {:ok, :parent, _, _, _} ->
            entity.relation(context, field)
        end
      end

      def evaluate(%{__struct__: entity} = context, [:**, ancestor | rest]) do
        case shortest_path(entity, ancestor) do
          [] ->
            if entity.name() == ancestor do
              evaluate(context, rest)
            else
              nil
            end

          path ->
            evaluate(context, path ++ rest)
        end
      end

      def evaluate(context, [field | _] = paths) when is_map(context) and is_list(field) do
        paths
        |> Enum.map(&evaluate(context, &1))
        |> List.flatten()
        |> Enum.reject(&is_nil/1)
        |> Enum.uniq()
      end

      def evaluate(%{__struct__: entity} = context, [field | rest]) do
        case entity.field_spec(field) do
          {:error, :unknown_field} ->
            nil

          {:ok, _kind, _column} ->
            nil

          {:ok, :child, _, _} ->
            context
            |> entity.relation(field)
            |> Enum.map(&evaluate(&1, rest))
            |> List.flatten()
            |> Enum.reject(&is_nil/1)
            |> Enum.uniq()

          {:ok, :parent, _, _, _} ->
            context
            |> entity.relation(field)
            |> evaluate(rest)
        end
      end

      def evaluate(context, [field | rest]) when is_map(context) and is_atom(field) do
        context
        |> Map.get(field)
        |> evaluate(rest)
      end
    end
  end
end
