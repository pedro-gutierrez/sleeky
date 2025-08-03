defmodule Sleeky.Feature.Generator.ListActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(feature, _) do
    for model <- feature.models, %{name: :list} <- model.actions() do
      [default_list_fun(model), list_by_parent_funs(model), list_by_key_funs(model)]
    end
  end

  defp default_list_fun(model) do
    action_fun_name = String.to_atom("list_#{model.plural()}")
    context = var(:context)
    query = var(:query)

    initial_query =
      quote do
        unquote(query) =
          unquote(model).query() |> maybe_filter(unquote(model.name()), unquote(context))
      end

    quote do
      def unquote(action_fun_name)(unquote(context) \\ %{}) do
        (unquote_splicing([
           initial_query,
           scope_query(model),
           query_opts(model),
           execute_query(model)
         ]))
      end
    end
  end

  defp list_by_parent_funs(model) do
    model_plural = model.plural()

    for rel <- model.parents() do
      column_name = rel.column_name
      parent_var = var(rel.name)
      action_fun_name = String.to_atom("list_#{model_plural}_by_#{rel.name}")
      query = var(:query)
      context = var(:context)

      initial_query =
        quote do
          unquote(query) =
            from(m in unquote(model).query(),
              where: m.unquote(column_name) == ^unquote(parent_var).id
            )
            |> maybe_filter(unquote(model.name()), unquote(context))
        end

      quote do
        def unquote(action_fun_name)(
              %unquote(rel.target.module){} = unquote(parent_var),
              unquote(context) \\ %{}
            ) do
          (unquote_splicing([
             initial_query,
             scope_query(model),
             query_opts(model),
             execute_query(model)
           ]))
        end
      end
    end
  end

  defp list_by_key_funs(model) do
    model_plural = model.plural()
    model_name = model.name()
    model_name_var = var(model_name)

    for key when key.unique? == false <- model.keys() do
      action_fun_name = String.to_atom("list_#{model_plural}_by_#{key.name}")
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
            from(unquote(model_name_var) in unquote(model).query(),
              where: unquote(filters)
            )
            |> maybe_filter(unquote(model_name), unquote(context))
        end

      quote do
        def unquote(action_fun_name)(unquote_splicing(args), unquote(context) \\ %{}) do
          (unquote_splicing([
             initial_query,
             scope_query(model),
             query_opts(model),
             execute_query(model)
           ]))
        end
      end
    end
  end

  defp scope_query(model) do
    query = var(:query)
    context = var(:context)
    model_name = model.name()

    quote do
      unquote(query) =
        scope(
          unquote(query),
          unquote(model_name),
          unquote(:list),
          unquote(context)
        )
    end
  end

  defp query_opts(_model) do
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

  defp execute_query(model) do
    opts = var(:opts)

    quote do
      unquote(model).list(unquote(opts))
    end
  end
end
