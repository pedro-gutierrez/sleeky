defmodule Bee.Entity.Ecto.Preload do
  @moduledoc false

  def ast(entity) do
    [
      preload_query_function(entity)
    ]
  end

  defp preload_query_function(entity) do
    case entity.preloads() do
      [] ->
        quote do
          def preload_query(query), do: {:ok, query}
        end

      preloads ->
        quote do
          def preload_query(query), do: {:ok, from(i in query, preload: ^unquote(preloads))}
        end
    end
  end
end
