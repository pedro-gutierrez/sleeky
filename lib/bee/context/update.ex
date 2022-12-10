defmodule Bee.Context.Update do
  @moduledoc false

  alias Bee.Entity
  import Bee.Inspector

  import Bee.Context.Helpers,
    only: [
      parent_function_args: 1,
      context_with_parents: 1,
      attrs_with_optional_parents: 1,
      attrs_with_required_parents: 1,
      context_with_args: 0,
      allowed?: 3
    ]

  def ast(entity, repo, auth) do
    action = Entity.action(:update, entity)

    if action do
      [
        update_function(entity, auth),
        do_update_function(entity, action, repo)
      ]
    else
      []
    end
  end

  defp update_function(entity, auth) do
    function_name = Entity.single_function_name(:update, entity)
    attrs = var(:attrs)
    context = var(:context)
    item = var(:item)

    quote do
      def unquote(function_name)(
            unquote_splicing(parent_function_args(entity)),
            %unquote(entity){} = unquote(item),
            unquote(attrs),
            unquote(context) \\ %{}
          ) do
        with unquote_splicing(
               flatten([
                 context_with_parents(entity),
                 context_with_item(entity),
                 attrs_with_required_parents(entity),
                 attrs_with_optional_parents(entity),
                 context_with_args(),
                 allowed?(entity, :update, auth)
               ])
             ),
             do: unquote(do_update(entity))
      end
    end
    |> print()
  end

  defp do_update_function(entity, action, repo) do
    function_name = Entity.single_function_name(:do_update, entity)
    attrs = var(:attrs)
    context = var(:context)
    item = var(:item)

    quote do
      defp unquote(function_name)(unquote(item), unquote(attrs), unquote(context) \\ %{}) do
        opts = unquote(context)[:opts] || []

        unquote(repo).transaction(fn ->
          (unquote_splicing(
             flatten([
               before_action(entity, action),
               update(entity, repo),
               after_action(entity, action)
             ])
           ))
        end)
      end
    end
    |> print()
  end

  defp do_update(entity) do
    function_name = Entity.single_function_name(:do_update, entity)
    attrs = var(:attrs)
    context = var(:context)
    item = var(:item)

    quote do
      unquote(function_name)(unquote(item), unquote(attrs), unquote(context))
    end
  end

  defp update(entity, repo) do
    item = var(:item)
    attrs = var(:attrs)

    quote do
      case unquote(item)
           |> unquote(entity).update_changeset(unquote(attrs))
           |> unquote(repo).update(opts) do
        {:ok, item} ->
          item

        {:error, reason} ->
          unquote(repo).rollback(reason)
      end
    end
  end

  defp context_with_item(entity) do
    context = var(:context)
    item = var(:item)

    quote do
      unquote(context) <- Map.put(unquote(context), unquote(entity.name()), unquote(item))
    end
  end

  defp before_action(_entity, _action) do
    nil
  end

  defp after_action(_entity, _action) do
    nil
  end
end
