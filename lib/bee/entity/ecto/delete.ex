defmodule Bee.Entity.Ecto.Delete do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  import Bee.Entity.Ecto.Helpers,
    only: [
      allowed?: 2,
      context_with_item: 1,
      item_id: 0,
      maybe_not_found_call: 0,
      repo_read_by_id: 1
    ]

  def ast(entity) do
    action = Entity.action(:delete, entity)

    if action do
      [
        delete_function(entity),
        do_delete_function(entity, action)
      ]
    else
      []
    end
  end

  defp delete_function(entity) do
    function_name = :delete
    do_function_name = :do_delete
    entity_module = entity.module
    context = var(:context)
    item = var(:item)

    quote do
      def unquote(function_name)(
            %unquote(entity_module){} = unquote(item),
            unquote(context) \\ %{}
          ) do
        with unquote_splicing(
               flatten([
                 item_id(),
                 repo_read_by_id(entity),
                 maybe_not_found_call(),
                 context_with_item(entity),
                 allowed?(entity, :delete)
               ])
             ),
             do: unquote(do_function_name)(unquote(item), unquote(context))
      end
    end
  end

  defp do_delete_function(entity, action) do
    function_name = :do_delete
    context = var(:context)
    item = var(:item)

    quote do
      defp unquote(function_name)(unquote(item), unquote(context) \\ %{}) do
        opts = unquote(context)[:opts] || []

        @repo.transaction(fn ->
          (unquote_splicing(
             flatten([
               before_action(entity, action),
               repo_delete(entity),
               after_action(entity, action)
             ])
           ))
        end)
      end
    end
  end

  defp repo_delete(entity) do
    entity_module = entity.module
    item = var(:item)

    quote do
      case unquote(item)
           |> unquote(entity_module).delete_changeset()
           |> @repo.delete(opts) do
        {:ok, item} ->
          item

        {:error, reason} ->
          @repo.rollback(reason)
      end
    end
  end

  defp before_action(_entity, _action) do
    nil
  end

  defp after_action(_entity, _action) do
    nil
  end
end
