defmodule Bee.Entity.Ecto.Helpers do
  @moduledoc false

  import Bee.Inspector

  def ast(_entity) do
    [
      imports(),
      pagination_arguments_function(),
      attrs_with_id(),
      ids_function(),
      maybe_id_function(),
      maybe_not_found(),
      list_function(),
      aggregate_function()
    ]
  end

  defp imports do
    quote do
      import Ecto.Query
      import Ecto.Changeset
    end
  end

  defp pagination_arguments_function do
    quote do
      defp pagination_arguments(context) do
        sort_field = Map.get(context, :sort_by) || :inserted_at
        sort_direction = Map.get(context, :sort_direction) || :asc
        limit = Map.get(context, :limit) || 20
        offset = Map.get(context, :offset) || 0

        {:ok, sort_field, sort_direction, limit, offset}
      end
    end
  end

  defp attrs_with_id do
    attrs = var(:attrs)

    [
      quote do
        defp with_id(%{id: _} = unquote(attrs)), do: unquote(attrs)
      end,
      quote do
        defp with_id(unquote(attrs)), do: Map.put(unquote(attrs), :id, Ecto.UUID.generate())
      end
    ]
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

  defp maybe_id_function do
    [
      quote do
        defp maybe_id(nil), do: nil
      end,
      quote do
        defp maybe_id(%{id: id}), do: id
      end
    ]
  end

  defp list_function do
    quote do
      defp list(query, entity, context) do
        with query <- @auth.scope_query(entity.name(), :list, query, context),
             {:ok, sort_field, sort_direction, limit, offset} <- pagination_arguments(context),
             {:ok, query} <-
               entity.paginate_query(query, sort_field, sort_direction, limit, offset),
             {:ok, query} <- entity.preload_query(query) do
          {:ok, @repo.all(query)}
        end
      end
    end
  end

  defp aggregate_function do
    quote do
      defp aggregate(query, entity, context) do
        with query <- @auth.scope_query(entity.name(), :list, query, context) do
          {:ok, %{count: @repo.aggregate(query, :count)}}
        end
      end
    end
  end

  def maybe_not_found do
    item = var(:item)

    [
      quote do
        defp maybe_not_found(nil), do: {:error, :not_found}
      end,
      quote do
        defp maybe_not_found(unquote(item)), do: {:ok, unquote(item)}
      end
    ]
  end

  def maybe_not_found_call do
    item = var(:item)

    quote do
      {:ok, unquote(item)} <- maybe_not_found(unquote(item))
    end
  end

  def item_id do
    item = var(:item)
    id = var(:id)

    quote do
      unquote(id) <- unquote(item).id
    end
  end

  def repo_read_by_id(entity) do
    entity_module = entity.module
    item = var(:item)
    id = var(:id)

    quote do
      unquote(item) <- @repo.get(unquote(entity_module), unquote(id))
    end
  end

  def context_with_parents(entity) do
    context = var(:context)

    for rel <- entity.parents do
      var = var(rel.name)

      quote do
        unquote(context) <- Map.put(unquote(context), unquote(rel.name), unquote(var))
      end
    end
  end

  def attrs_with_required_parents(entity) do
    attrs = var(:attrs)

    for rel <- entity.parents |> Enum.filter(& &1.required) do
      column = rel.column
      var = var(rel.name)

      quote do
        unquote(attrs) <- Map.put(unquote(attrs), unquote(column), unquote(var).id)
      end
    end
  end

  def attrs_with_optional_parents(entity) do
    attrs = var(:attrs)

    for rel <- entity.parents |> Enum.reject(& &1.required) do
      column = rel.column
      var = var(rel.name)

      quote do
        unquote(attrs) <- Map.put(unquote(attrs), unquote(column), maybe_id(unquote(var)))
      end
    end
  end

  def context_with_args do
    context = var(:context)
    attrs = var(:attrs)

    quote do
      unquote(context) <- Map.put(unquote(context), :args, unquote(attrs))
    end
  end

  def context_with_item(entity) do
    entity_name = entity.name
    context = var(:context)
    item = var(:item)

    quote do
      unquote(context) <- Map.put(unquote(context), unquote(entity_name), unquote(item))
    end
  end

  def allowed?(entity, action) do
    entity_name = entity.name
    context = var(:context)

    quote do
      :ok <- @auth.allow_action(unquote(entity_name), unquote(action), unquote(context))
    end
  end

  def parent_function_args(entity) do
    for rel <- entity.parents() do
      quote do
        %unquote(rel.target.module){} = unquote(var(rel.name))
      end
    end
  end
end
