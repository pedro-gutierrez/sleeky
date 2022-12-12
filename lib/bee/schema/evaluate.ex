defmodule Bee.Schema.Evaluate do
  @moduledoc false

  def ast(_schema) do
    [
      nil_context(),
      empty_path(),
      app_env(),
      literal(),
      trailing_wildcard(),
      trailing_field(),
      nearest_path()
    ]
  end

  defp nil_context do
    quote do
      def evaluate(nil, _), do: nil
    end
  end

  defp empty_path do
    quote do
      def evaluate(value, []), do: value
    end
  end

  defp app_env do
    quote do
      def evaluate(_, %{app: app, env: env, key: key}) do
        app |> Application.fetch_env!(env) |> Keyword.fetch!(key)
      end
    end
  end

  defp literal do
    quote do
      def evaluate(_, {:literal, v}), do: v
    end
  end

  defp trailing_wildcard do
    quote do
      def evaluate(%{__struct__: _} = context, [:"**"]), do: context
    end
  end

  defp trailing_field do
    quote do
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
            |> entity.relation(context, field)
            |> Enum.reject(&is_nil/1)

          {:ok, :parent, _, _, _} ->
            entity.relation(context, field)
        end
      end
    end
  end

  defp nearest_path do
    quote do
      def evaluate(%{__struct__: entity} = context, [:"**", ancestor | rest]) do
        case nearest_path(entity, ancestor) do
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
    end
  end

  #  def evaluate(context, [field | _] = paths) when is_map(context) and is_list(field) do
  #    paths
  #    |> Enum.map(&evaluate(context, &1))
  #    |> List.flatten()
  #    |> Enum.reject(&is_nil/1)
  #    |> Enum.uniq()
  #  end

  #  def evaluate(%{__struct__: schema} = context, [field | rest]) do
  #    case schema.field_spec(field) do
  #      {:error, :unknown_field} ->
  #        nil

  #      {:ok, _kind, _column} ->
  #        nil

  #      {:ok, :has_many, _, _next_schema} ->
  #        context
  #        |> relation(field)
  #        |> Enum.map(&evaluate(&1, rest))
  #        |> List.flatten()
  #        |> Enum.reject(&is_nil/1)
  #        |> Enum.uniq()

  #      {:ok, :belongs_to, _, _next_schema, _} ->
  #        context
  #        |> relation(field)
  #        |> evaluate(rest)
  #    end
  #  end

  #  def evaluate(context, [field | rest]) when is_map(context) and is_atom(field) do
  #    context
  #    |> Map.get(field)
  #    |> evaluate(rest)
  #  end
end
