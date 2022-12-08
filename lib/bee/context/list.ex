defmodule Bee.Context.List do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  def ast(entities, _enums, opts) do
    entities
    |> Enum.reject(& &1.virtual?)
    |> Enum.filter(&Entity.action(:list, &1))
    |> Enum.map(fn entity ->
      [
        list_all_function(entity),
        list_by_ids_function(entity),
        list_by_parents_functions(entity),
        list_by_non_unique_keys_functions(entity),
        query_function(entity, opts)
      ]
    end)
    |> flatten()
  end

  defp list_all_function(entity) do
    function_name = Entity.list_all_function(entity)
    query_function_name = Entity.query_function(entity)
    entity_name = entity.name()

    quote do
      def unquote(function_name)(context \\ %{}) do
        from(item in unquote(entity), as: unquote(entity_name))
        |> unquote(query_function_name)(context)
      end
    end
  end

  defp list_by_ids_function(entity) do
    function_name = Entity.list_by_function(entity, :ids)
    query_function_name = Entity.query_function(entity)
    entity_name = entity.name()

    quote do
      def unquote(function_name)(ids, context \\ %{}) do
        ids = ids(ids)

        from(item in unquote(entity), as: unquote(entity_name))
        |> where([item], item.id in ^ids)
        |> unquote(query_function_name)(context)
      end
    end
  end

  defp list_by_parents_functions(entity) do
    query_function_name = Entity.query_function(entity)
    entity_name = entity.name()

    for rel <- entity.parents() do
      function_name = Entity.list_by_function(entity, rel.name)

      quote do
        def unquote(function_name)(ids, context \\ %{}) do
          ids = ids(ids)

          from(item in unquote(entity), as: unquote(entity_name))
          |> where([item], item.unquote(rel.column) in ^ids)
          |> unquote(query_function_name)(context)
        end
      end
    end
  end

  defp list_by_non_unique_keys_functions(entity) do
    query_function_name = Entity.query_function(entity)
    entity_name = entity.name()

    for key <- entity.keys() |> Enum.reject(& &1.unique) do
      function_name = key.list_function_name
      args = key.fields |> names() |> vars()

      filters =
        for field <- key.fields do
          {:ok, column} = entity.column_for(field.name)
          var = var(field.name)

          quote do
            query = where(query, [q], q.unquote(column) == ^unquote(var))
          end
        end

      quote do
        def unquote(function_name)(unquote_splicing(args), context \\ %{}) do
          query = from(item in unquote(entity), as: unquote(entity_name))

          unquote_splicing(filters)
          query |> unquote(query_function_name)(context)
        end
      end
    end
  end

  defp query_function(entity, opts) do
    repo = Keyword.fetch!(opts, :repo)
    auth = Keyword.fetch!(opts, :auth)
    function_name = Entity.query_function(entity)

    quote do
      defp unquote(function_name)(query, context) do
        with query <- unquote(auth).scope_query(unquote(entity.name), :list, query, context),
             {:ok, sort_field, sort_direction, limit, offset} <- pagination_arguments(context),
             {:ok, query} <-
               unquote(entity).paginate_query(query, sort_field, sort_direction, limit, offset),
             {:ok, query} <- unquote(entity).preload_query(query) do
          {:ok, unquote(repo).all(query)}
        end
      end
    end
  end
end
