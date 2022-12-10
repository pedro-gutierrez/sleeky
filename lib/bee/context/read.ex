defmodule Bee.Context.Read do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  import Bee.Context.Helpers,
    only: [
      allowed?: 3,
      context_with_item: 1,
      maybe_not_found_call: 0,
      repo_read_by_id: 2
    ]

  def ast(entity, repo, auth) do
    if Entity.action(:read, entity) do
      [
        read_by_id_function(entity, repo, auth),
        read_by_unique_key_functions(entity, repo, auth)
      ]
    else
      []
    end
  end

  defp read_by_id_function(entity, repo, auth) do
    function_name = Entity.single_function_name(:read, entity)
    context = var(:context)
    id = var(:id)
    item = var(:item)

    quote do
      def unquote(function_name)(unquote(id), unquote(context) \\ %{}) do
        preloads = unquote(context)[:preloads] || []

        with unquote_splicing(
               flatten([
                 repo_read_by_id(entity, repo),
                 preload_item(repo),
                 maybe_not_found_call(),
                 context_with_item(entity),
                 allowed?(entity, :read, auth)
               ])
             ),
             do: {:ok, unquote(item)}
      end
    end
  end

  defp read_by_unique_key_functions(entity, repo, auth) do
    context = var(:context)
    item = var(:item)

    for key <- entity.keys() |> Enum.filter(& &1.unique) do
      function_name = key.read_function_name
      args = key.fields |> names() |> vars()

      quote do
        def unquote(function_name)(unquote_splicing(args), unquote(context) \\ %{}) do
          preloads = unquote(context)[:preloads] || []

          with unquote_splicing(
                 flatten([
                   repo_read_by_key(entity, repo, key),
                   preload_item(repo),
                   maybe_not_found_call(),
                   context_with_item(entity),
                   allowed?(entity, :read, auth)
                 ])
               ),
               do: {:ok, unquote(item)}
        end
      end
    end
  end

  defp repo_read_by_key(entity, repo, key) do
    filters =
      for field <- key.fields do
        {:ok, column} = entity.column_for(field.name)
        var = var(field.name)

        quote do
          {unquote(column), unquote(var)}
        end
      end

    item = var(:item)

    quote do
      unquote(item) <- unquote(repo).get_by(unquote(entity), [unquote_splicing(filters)])
    end
  end

  defp preload_item(repo) do
    item = var(:item)

    quote do
      unquote(item) <- unquote(repo).preload(unquote(item), preloads)
    end
  end
end
