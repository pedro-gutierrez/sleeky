defmodule Bee.Context.List do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  def ast(entities, _enums, _opts) do
    entities
    |> Enum.reject(& &1.virtual?)
    |> Enum.filter(&Entity.action(:list, &1))
    |> Enum.map(fn entity ->
      [
        list_all_function(entity),
        aggregate_all_function(entity),
        list_by_ids_function(entity),
        list_by_parents_functions(entity),
        aggregate_by_parents_functions(entity),
        list_by_non_unique_keys_functions(entity),
        aggregate_by_non_unique_keys_functions(entity)
      ]
    end)
    |> flatten()
  end

  defp list_all_function(entity) do
    function_name = Entity.list_all_function(entity)
    entity_name = entity.name()

    quote do
      def unquote(function_name)(context \\ %{}) do
        from(item in unquote(entity), as: unquote(entity_name))
        |> list(unquote(entity), context)
      end
    end
  end

  defp aggregate_all_function(entity) do
    function_name = Entity.aggregate_all_function(entity)
    entity_name = entity.name()

    quote do
      def unquote(function_name)(context \\ %{}) do
        from(item in unquote(entity), as: unquote(entity_name))
        |> aggregate(unquote(entity), context)
      end
    end
  end

  defp list_by_ids_function(entity) do
    function_name = Entity.list_by_function(entity, :ids)
    entity_name = entity.name()

    quote do
      def unquote(function_name)(ids, context \\ %{}) do
        ids = ids(ids)

        from(item in unquote(entity), as: unquote(entity_name))
        |> where([item], item.id in ^ids)
        |> list(unquote(entity), context)
      end
    end
  end

  defp list_by_parents_functions(entity) do
    entity_name = entity.name()

    for rel <- entity.parents() do
      function_name = Entity.list_by_function(entity, rel.name)

      quote do
        def unquote(function_name)(ids, context \\ %{}) do
          ids = ids(ids)

          from(item in unquote(entity), as: unquote(entity_name))
          |> where([item], item.unquote(rel.column) in ^ids)
          |> list(unquote(entity), context)
        end
      end
    end
  end

  defp aggregate_by_parents_functions(entity) do
    entity_name = entity.name()

    for rel <- entity.parents() do
      function_name = Entity.aggregate_by_function(entity, rel.name)

      quote do
        def unquote(function_name)(ids, context \\ %{}) do
          ids = ids(ids)

          from(item in unquote(entity), as: unquote(entity_name))
          |> where([item], item.unquote(rel.column) in ^ids)
          |> aggregate(unquote(entity), context)
        end
      end
    end
  end

  defp list_by_non_unique_keys_functions(entity) do
    entity_name = entity.name()

    for key <- entity.keys() |> Enum.reject(& &1.unique) do
      function_name = key.list_function_name
      args = key.fields |> names() |> vars()

      filters = query_filters_for_key(entity, key)

      quote do
        def unquote(function_name)(unquote_splicing(args), context \\ %{}) do
          query = from(item in unquote(entity), as: unquote(entity_name))

          unquote_splicing(filters)
          list(query, unquote(entity), context)
        end
      end
    end
  end

  defp aggregate_by_non_unique_keys_functions(entity) do
    entity_name = entity.name()

    for key <- entity.keys() |> Enum.reject(& &1.unique) do
      function_name = key.aggregate_function_name
      args = key.fields |> names() |> vars()

      filters = query_filters_for_key(entity, key)

      quote do
        def unquote(function_name)(unquote_splicing(args), context \\ %{}) do
          query = from(item in unquote(entity), as: unquote(entity_name))

          unquote_splicing(filters)
          aggregate(query, unquote(entity), context)
        end
      end
    end
  end

  defp query_filters_for_key(entity, key) do
    for field <- key.fields do
      {:ok, column} = entity.column_for(field.name)
      var = var(field.name)

      quote do
        query = where(query, [q], q.unquote(column) == ^unquote(var))
      end
    end
  end
end
