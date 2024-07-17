defmodule Sleeky.Context.Generator.ListActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming

  alias Sleeky.Model.Action

  @impl true
  def generate(context, _) do
    for model <- context.models, %Action{name: :list} <- model.actions() do
      [default_list_fun(model), list_by_parent_funs(model)]
    end
  end

  defp default_list_fun(model) do
    action_fun_name = String.to_atom("list_#{model.plural()}")
    context = var(:context)
    query = var(:query)

    quote do
      def unquote(action_fun_name)(unquote(context)) do
        unquote(query) =
          unquote(model).query() |> maybe_filter(unquote(model.name()), unquote(context))

        unquote(scope_and_list(model))
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

      quote do
        def unquote(action_fun_name)(
              %unquote(rel.target.module){} = unquote(parent_var),
              unquote(context)
            ) do
          unquote(query) =
            from(m in unquote(model).query(),
              where: m.unquote(column_name) == ^unquote(parent_var).id
            )
            |> maybe_filter(unquote(model.name()), unquote(context))

          unquote(scope_and_list(model))
        end
      end
    end
  end

  defp scope_and_list(model) do
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

      opts =
        unquote(context)
        |> Map.take([:limit, :before, :after, :preload, :sort])
        |> Keyword.new()
        |> Keyword.put(:query, unquote(query))

      unquote(model).list(opts)
    end
  end
end
