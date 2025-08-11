defmodule Sleeky.Feature.Generator.Queries do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _opts) do
    for query <- feature.queries do
      fun_name = Sleeky.Query.fun_name(query)
      params_module = query.params()

      if params_module != nil do
        quote do
          def unquote(fun_name)(params, context \\ %{}),
            do: Sleeky.Query.execute(unquote(query), params, context)
        end
      else
        quote do
          def unquote(fun_name)(context \\ %{}), do: Sleeky.Query.execute(unquote(query), context)
        end
      end
    end
  end
end
