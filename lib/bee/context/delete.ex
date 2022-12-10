defmodule Bee.Context.Delete do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  import Bee.Context.Helpers,
    only: [
      allowed?: 3,
      context_with_item: 1,
      item_id: 0,
      maybe_not_found_call: 0,
      repo_read_by_id: 2
    ]

  def ast(entity, repo, auth) do
    action = Entity.action(:delete, entity)

    if action do
      [
        delete_function(entity, repo, auth),
        do_delete_function(entity, action, repo)
      ]
    else
      []
    end
  end

  defp delete_function(entity, repo, auth) do
    function_name = Entity.single_function_name(:delete, entity)
    do_function_name = Entity.single_function_name(:do_delete, entity)
    context = var(:context)
    item = var(:item)

    quote do
      def unquote(function_name)(
            %unquote(entity){} = unquote(item),
            unquote(context) \\ %{}
          ) do
        with unquote_splicing(
               flatten([
                 item_id(),
                 repo_read_by_id(entity, repo),
                 maybe_not_found_call(),
                 context_with_item(entity),
                 allowed?(entity, :delete, auth)
               ])
             ),
             do: unquote(do_function_name)(unquote(item), unquote(context))
      end
    end
  end

  defp do_delete_function(entity, action, repo) do
    function_name = Entity.single_function_name(:do_delete, entity)
    context = var(:context)
    item = var(:item)

    quote do
      defp unquote(function_name)(unquote(item), unquote(context) \\ %{}) do
        opts = unquote(context)[:opts] || []

        unquote(repo).transaction(fn ->
          (unquote_splicing(
             flatten([
               before_action(entity, action),
               repo_delete(entity, repo),
               after_action(entity, action)
             ])
           ))
        end)
      end
    end
  end

  defp repo_delete(entity, repo) do
    item = var(:item)

    quote do
      case unquote(item)
           |> unquote(entity).delete_changeset()
           |> unquote(repo).delete(opts) do
        {:ok, item} ->
          item

        {:error, reason} ->
          unquote(repo).rollback(reason)
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
