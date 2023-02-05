defmodule Bee.Entity.Ecto.FuzzySearch do
  @moduledoc "Naive fuzzy search capabilities for entities"

  def ast(entity) do
    [
      default_fuzzy_search_function(),
      fuzzy_search_function(entity)
    ]
  end

  defp default_fuzzy_search_function do
    quote do
      def fuzzy_search(query, nil), do: query
    end
  end

  defp fuzzy_search_function(entity) do
    [first | rest] =
      entity.attributes
      |> Enum.reject(& &1.virtual)
      |> Enum.reject(& &1.implied)
      |> Enum.filter(&(&1.kind in [:string, :text]))

    first =
      quote do
        query = where(query, [item], ilike(item.unquote(first.column), ^q))
      end

    rest =
      for attr <- rest do
        quote do
          query = or_where(query, [item], ilike(item.unquote(attr.column), ^q))
        end
      end

    quote do
      def fuzzy_search(query, q) when is_binary(q) do
        q = "%#{q}%"
        unquote(first)
        unquote_splicing(rest)
      end
    end
  end
end
