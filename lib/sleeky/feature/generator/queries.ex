defmodule Sleeky.Feature.Generator.Queries do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _opts) do
    for query <- feature.queries do
      query_fun(query, feature)
    end
  end

  def query_fun(query, feature) do
    fun_name = Sleeky.Query.fun_name(query)
    params_module = query.params()
    handler_module = query.handler()
    repo = feature.repo

    query_execution =
      if query.many?() do
        quote do
          unquote(repo).all(q)
        end
      else
        quote do
          case unquote(repo).one(q) do
            nil -> {:error, :not_found}
            item -> {:ok, item}
          end
        end
      end

    if params_module != nil do
      quote do
        def unquote(fun_name)(params, context \\ %{}) do
          with {:ok, params} <- unquote(params_module).validate(params),
               context <- Map.put(context, :params, params) do
            q =
              context
              |> unquote(query).scope()
              |> unquote(handler_module).execute(params, context)

            unquote(query_execution)
          end
        end
      end
    else
      quote do
        def unquote(fun_name)(context \\ %{}) do
          q =
            context
            |> unquote(query).scope()
            |> unquote(handler_module).execute(context)

          unquote(query_execution)
        end
      end
    end
  end
end
