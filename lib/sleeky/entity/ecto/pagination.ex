defmodule Sleeky.Entity.Ecto.Pagination do
  @moduledoc false

  def ast(_entity) do
    [
      paginate_query_function()
    ]
  end

  defp paginate_query_function do
    quote do
      def paginate_query(query, sort_field, sort_direction, limit, offset) do
        with {:ok, column} <- column_for(sort_field) do
          opts = [{sort_direction, column}]
          query = query |> order_by(^opts) |> limit(^limit) |> offset(^offset)

          {:ok, query}
        end
      end
    end
  end
end
