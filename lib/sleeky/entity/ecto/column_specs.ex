defmodule Sleeky.Entity.Ecto.ColumnSpecs do
  @moduledoc false

  def ast(entity) do
    [
      attributes(entity),
      parents(entity),
      default()
    ]
  end

  defp attributes(entity) do
    attrs = Enum.reject(entity.attributes, & &1.virtual)

    for attr <- attrs do
      aliases = attr.aliases

      quote do
        def column_for(f) when f in unquote(aliases), do: {:ok, unquote(attr.column)}
      end
    end
  end

  defp parents(entity) do
    for rel <- entity.parents do
      aliases = rel.aliases

      quote do
        def column_for(f) when f in unquote(aliases), do: {:ok, unquote(rel.column)}
      end
    end
  end

  defp default do
    quote do
      def column_for(_), do: {:error, :unknown_field}
    end
  end
end
