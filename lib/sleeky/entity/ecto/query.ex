defmodule Sleeky.Entity.Ecto.Query do
  @moduledoc false

  import Sleeky.Inspector

  def ast(entity) do
    [
      query_function(entity)
    ]
  end

  defp query_function(entity) do
    item = var(:item)
    entity_module = entity.module
    alias = entity.name

    quote do
      def query, do: from(unquote(item) in unquote(entity_module), as: unquote(alias))
    end
  end
end
