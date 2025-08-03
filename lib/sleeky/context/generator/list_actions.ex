defmodule Sleeky.Context.Generator.ListActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(context, _) do
    for entity <- context.entities, %{name: :list} <- entity.actions() do
      [default_list_fun(entity), list_by_parent_funs(entity), list_by_key_funs(entity)]
    end
  end

  defp default_list_fun(entity) do
    action_fun_name = String.to_atom("list_#{entity.plural()}")
    context = var(:context)
    query = var(:query)

    initial_query =
      quote do
        unquote(query) =
          unquote(entity).query() |> maybe_filter(unquote(entity.name()), unquote(context))
      end

    quote do
      def unquote(action_fun_name)(unquote(context) \\ %{}) do
        (unquote_splicing([
           initial_query,
           scope_query(entity),
           query_opts(entity),
           execute_query(entity)
         ]))
      end
    end
  end

  defp list_by_parent_funs(entity) do
    entity_plural = entity.plural()

    for rel <- entity.parents() do
      column_name = rel.column_name
      parent_var = var(rel.name)
      action_fun_name = String.to_atom("list_#{entity_plural}_by_#{rel.name}")
      query = var(:query)
      context = var(:context)

      initial_query =
        quote do
          unquote(query) =
            from(m in unquote(entity).query(),
              where: m.unquote(column_name) == ^unquote(parent_var).id
            )
            |> maybe_filter(unquote(entity.name()), unquote(context))
        end

      quote do
        def unquote(action_fun_name)(
              %unquote(rel.target.module){} = unquote(parent_var),
              unquote(context) \\ %{}
            ) do
          (unquote_splicing([
             initial_query,
             scope_query(entity),
             query_opts(entity),
             execute_query(entity)
           ]))
        end
      end
    end
  end

  defp list_by_key_funs(entity) do
    entity_plural = entity.plural()
    entity_name = entity.name()
    entity_name_var = var(entity_name)

    for key when key.unique? == false <- entity.keys() do
      action_fun_name = String.to_atom("list_#{entity_plural}_by_#{key.name}")
      query = var(:query)
      context = var(:context)
      fields = for field <- key.fields, do: field.name
      args = for field <- fields, do: var(field)

      filters =
        for field <- fields do
          quote do
            {unquote(field), ^unquote(var(field))}
          end
        end

      initial_query =
        quote do
          unquote(query) =
            from(unquote(entity_name_var) in unquote(entity).query(),
              where: unquote(filters)
            )
            |> maybe_filter(unquote(entity_name), unquote(context))
        end

      quote do
        def unquote(action_fun_name)(unquote_splicing(args), unquote(context) \\ %{}) do
          (unquote_splicing([
             initial_query,
             scope_query(entity),
             query_opts(entity),
             execute_query(entity)
           ]))
        end
      end
    end
  end

  defp scope_query(entity) do
    query = var(:query)
    context = var(:context)
    entity_name = entity.name()

    quote do
      unquote(query) =
        scope(
          unquote(query),
          unquote(entity_name),
          unquote(:list),
          unquote(context)
        )
    end
  end

  defp query_opts(_entity) do
    query = var(:query)
    context = var(:context)
    opts = var(:opts)

    quote do
      unquote(opts) =
        unquote(context)
        |> Map.take([:limit, :before, :after, :preload, :sort])
        |> Keyword.new()
        |> Keyword.put(:query, unquote(query))
    end
  end

  defp execute_query(entity) do
    opts = var(:opts)

    quote do
      unquote(entity).list(unquote(opts))
    end
  end
end
