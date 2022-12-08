defmodule Bee.Context.Helpers do
  @moduledoc false

  import Bee.Inspector

  def ast(_entities, _enums, _opts) do
    flatten([
      pagination_arguments_function(),
      ids_function()
    ])
  end

  defp pagination_arguments_function do
    quote do
      defp pagination_arguments(context) do
        sort_field = Map.get(context, :sort_by, :inserted_at)
        sort_direction = Map.get(context, :sort_direction, :asc)
        limit = Map.get(context, :limit, 20)
        offset = Map.get(context, :offset, 0)

        {:ok, sort_field, sort_direction, limit, offset}
      end
    end
  end

  defp ids_function do
    [
      quote do
        defp ids(id) when is_binary(id), do: [id]
      end,
      quote do
        defp ids(ids) when is_list(ids), do: ids
      end
    ]
  end
end
