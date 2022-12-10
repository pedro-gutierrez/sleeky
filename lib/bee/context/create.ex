defmodule Bee.Context.Create do
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
    action = Entity.action(:create, entity)

    if action do
      [
        create_function(entity, auth),
        do_create_function(entity, action, repo)
      ]
    else
      []
    end
  end

  defp create_function(entity, auth) do
    function_name = Entity.single_function_name(:create, entity)
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
                 context_with_args(),
                 allowed?(entity, :create, auth)
               ])
             ),
             do: unquote(do_create(entity))
      end
    end
    |> print()
  end

  defp do_create_function(entity, action, repo) do
    function_name = Entity.single_function_name(:do_create, entity)
    attrs = var(:attrs)
    context = var(:context)

    quote do
      defp unquote(function_name)(unquote(attrs), unquote(context) \\ %{}) do
        opts = unquote(context)[:opts] || []

        unquote(repo).transaction(fn ->
          (unquote_splicing(
             flatten([
               before_action(entity, action),
               insert(entity, repo),
               after_action(entity, action)
             ])
           ))
        end)
      end
    end
    |> print()
  end

  defp do_create(entity) do
    function_name = Entity.single_function_name(:do_create, entity)
    attrs = var(:attrs)
    context = var(:context)

    quote do
      unquote(function_name)(unquote(attrs), unquote(context))
    end
  end

  defp insert(entity, repo) do
    attrs = var(:attrs)

    quote do
      case %unquote(entity){}
           |> unquote(entity).insert_changeset(unquote(attrs))
           |> unquote(repo).insert(opts) do
        {:ok, item} ->
          item

        {:error, reason} ->
          unquote(repo).rollback(reason)
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
