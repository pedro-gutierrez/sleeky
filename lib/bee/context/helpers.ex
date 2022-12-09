defmodule Bee.Context.Helpers do
  @moduledoc false

  import Bee.Inspector

  def ast(_entities, _enums, opts) do
    repo = Keyword.fetch!(opts, :repo)
    auth = Keyword.fetch!(opts, :auth)

    flatten([
      pagination_arguments_function(),
      ids_function(),
      list_function(repo, auth),
      aggregate_function(repo, auth),
      check_allowed_functions(auth)
    ])
  end

  defp pagination_arguments_function do
    quote do
      defp pagination_arguments(context) do
        sort_field = Map.get(context, :sort_by, :inserted_at)
        sort_direction = Map.get(context, :sort_direction, :asc)
        limit = Map.get(context, :limit, 20)
        offset = Map.get(context, :offset, 0)

        {:ok, sort_field, sort_direction, limit, offset}
      end
    end
  end

  defp ids_function do
    [
      quote do
        defp ids(id) when is_binary(id), do: [id]
      end,
      quote do
        defp ids(ids) when is_list(ids), do: ids
      end
    ]
  end

  defp list_function(repo, auth) do
    quote do
      defp list(query, entity, context) do
        with query <- unquote(auth).scope_query(entity.name(), :list, query, context),
             {:ok, sort_field, sort_direction, limit, offset} <- pagination_arguments(context),
             {:ok, query} <-
               entity.paginate_query(query, sort_field, sort_direction, limit, offset),
             {:ok, query} <- entity.preload_query(query) do
          {:ok, unquote(repo).all(query)}
        end
      end
    end
  end

  defp aggregate_function(repo, auth) do
    quote do
      defp aggregate(query, entity, context) do
        with query <- unquote(auth).scope_query(entity.name(), :list, query, context) do
          {:ok, %{count: unquote(repo).aggregate(query, :count)}}
        end
      end
    end
  end

  defp check_allowed_functions(auth) do
    [
      quote do
        defp check_allowed(nil, _, _, _), do: {:error, :not_found}
      end,
      quote do
        defp check_allowed(item, entity, action, context) do
          context = Map.put(context, entity.name(), item)

          case unquote(auth).allowed?(entity.name(), action, context) do
            false -> {:error, :unauthorized}
            true -> {:ok, item}
          end
        end
      end
    ]
  end
end
