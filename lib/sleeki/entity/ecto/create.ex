defmodule Sleeki.Entity.Ecto.Create do
  @moduledoc false

  alias Sleeki.Entity
  import Sleeki.Inspector

  import Sleeki.Entity.Ecto.Helpers,
    only: [
      parent_function_args: 1,
      context_with_parents: 1,
      attrs_with_optional_parents: 1,
      attrs_with_required_parents: 1,
      attrs_with_computed_attributes: 1,
      context_with_args: 0,
      allowed?: 2
    ]

  def ast(entity) do
    action = Entity.action(:create, entity)

    if action do
      [
        create_function(entity),
        do_create_function(entity, action)
      ]
    else
      []
    end
  end

  defp create_function(entity) do
    function_name = :create
    do_function_name = :do_create
    attrs = var(:attrs)
    context = var(:context)

    quote do
      def unquote(function_name)(
            unquote_splicing(parent_function_args(entity)),
            unquote(attrs),
            unquote(context) \\ %{}
          ) do
        with unquote_splicing(
               flatten([
                 context_with_parents(entity),
                 attrs_with_id(),
                 attrs_with_required_parents(entity),
                 attrs_with_optional_parents(entity),
                 attrs_with_computed_attributes(entity),
                 context_with_args(),
                 allowed?(entity, :create)
               ])
             ),
             do: unquote(do_function_name)(unquote(attrs), unquote(context))
      end
    end
  end

  defp do_create_function(entity, action) do
    function_name = :do_create
    attrs = var(:attrs)
    context = var(:context)

    quote do
      defp unquote(function_name)(unquote(attrs), unquote(context) \\ %{}) do
        opts = unquote(context)[:opts] || []

        @repo.transaction(fn ->
          (unquote_splicing(
             flatten([
               before_action(entity, action),
               repo_insert(entity),
               after_action(entity, action)
             ])
           ))
        end)
      end
    end
  end

  defp repo_insert(entity) do
    attrs = var(:attrs)
    entity_module = entity.module

    quote do
      case %unquote(entity_module){}
           |> unquote(entity_module).insert_changeset(unquote(attrs))
           |> @repo.insert(opts) do
        {:ok, item} ->
          item

        {:error, reason} ->
          @repo.rollback(reason)
      end
    end
  end

  defp attrs_with_id do
    attrs = var(:attrs)

    quote do
      unquote(attrs) <- with_id(unquote(attrs))
    end
  end

  defp before_action(_entity, _action) do
    nil
  end

  defp after_action(_entity, _action) do
    nil
  end
end
