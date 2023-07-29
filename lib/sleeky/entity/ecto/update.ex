defmodule Sleeky.Entity.Ecto.Update do
  @moduledoc false

  alias Sleeky.Entity
  import Sleeky.Inspector

  import Sleeky.Entity.Ecto.Helpers,
    only: [
      parent_function_args: 1,
      context_with_parents: 1,
      attrs_with_optional_parents: 1,
      attrs_with_required_parents: 1,
      attrs_with_computed_attributes: 1,
      context_with_args: 0,
      context_with_item: 1,
      allowed?: 2
    ]

  def ast(entity) do
    action = Entity.action(:update, entity)

    if action do
      [
        update_function(entity),
        do_update_function(entity, action)
      ]
    else
      []
    end
  end

  defp update_function(entity) do
    function_name = :update
    do_function_name = :do_update
    entity_module = entity.module
    attrs = var(:attrs)
    context = var(:context)
    item = var(:item)

    quote do
      def unquote(function_name)(
            unquote_splicing(parent_function_args(entity)),
            %unquote(entity_module){} = unquote(item),
            unquote(attrs),
            unquote(context) \\ %{}
          ) do
        with unquote_splicing(
               flatten([
                 context_with_parents(entity),
                 context_with_item(entity),
                 attrs_with_required_parents(entity),
                 attrs_with_optional_parents(entity),
                 attrs_with_computed_attributes(entity),
                 context_with_args(),
                 allowed?(entity, :update)
               ])
             ),
             do: unquote(do_function_name)(unquote(item), unquote(attrs), unquote(context))
      end
    end
  end

  defp do_update_function(entity, action) do
    function_name = :do_update
    attrs = var(:attrs)
    context = var(:context)
    item = var(:item)

    quote do
      defp unquote(function_name)(unquote(item), unquote(attrs), unquote(context) \\ %{}) do
        opts = unquote(context)[:opts] || []

        @repo.transaction(fn ->
          (unquote_splicing(
             flatten([
               before_action(entity, action),
               repo_update(entity),
               after_action(entity, action)
             ])
           ))
        end)
      end
    end
  end

  defp repo_update(entity) do
    entity_module = entity.module
    item = var(:item)
    attrs = var(:attrs)

    quote do
      case unquote(item)
           |> unquote(entity_module).update_changeset(unquote(attrs))
           |> @repo.update(opts) do
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
