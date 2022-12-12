defmodule Bee.Entity.Ecto.Read do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  import Bee.Entity.Ecto.Helpers,
    only: [
      allowed?: 2,
      context_with_item: 1,
      maybe_not_found_call: 0,
      repo_read_by_id: 1
    ]

  def ast(entity) do
    if Entity.action(:read, entity) do
      [
        read_by_id_function(entity),
        read_by_unique_key_functions(entity)
      ]
    else
      []
    end
  end

  defp read_by_id_function(entity) do
    function_name = :read
    context = var(:context)
    id = var(:id)
    item = var(:item)

    quote do
      def unquote(function_name)(unquote(id), unquote(context) \\ %{}) do
        preloads = unquote(context)[:preloads] || []

        with unquote_splicing(
               flatten([
                 repo_read_by_id(entity),
                 preload_item(),
                 maybe_not_found_call(),
                 context_with_item(entity),
                 allowed?(entity, :read)
               ])
             ),
             do: {:ok, unquote(item)}
      end
    end
  end

  defp read_by_unique_key_functions(entity) do
    context = var(:context)
    item = var(:item)

    for key <- entity.keys() |> Enum.filter(& &1.unique) do
      function_name = function_name(:read_by, names(key.fields))
      args = key.fields |> names() |> vars()

      quote do
        def unquote(function_name)(unquote_splicing(args), unquote(context) \\ %{}) do
          preloads = unquote(context)[:preloads] || []

          with unquote_splicing(
                 flatten([
                   repo_read_by_key(entity, key),
                   preload_item(),
                   maybe_not_found_call(),
                   context_with_item(entity),
                   allowed?(entity, :read)
                 ])
               ),
               do: {:ok, unquote(item)}
        end
      end
    end
  end

  defp repo_read_by_key(entity, key) do
    entity_module = entity.module

    filters =
      for field <- key.fields do
        column = field.column
        var = var(field.name)

        quote do
          {unquote(column), unquote(var)}
        end
      end

    item = var(:item)

    quote do
      unquote(item) <- @repo.get_by(unquote(entity_module), [unquote_splicing(filters)])
    end
  end

  defp preload_item do
    item = var(:item)

    quote do
      unquote(item) <- @repo.preload(unquote(item), preloads)
    end
  end
end
