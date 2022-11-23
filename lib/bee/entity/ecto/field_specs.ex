defmodule Bee.Entity.Ecto.FieldSpecs do
  @moduledoc false
  import Bee.Inspector

  def ast(entity) do
    quote do
      (unquote_splicing(
         flatten([
           attributes(entity),
           parents(entity),
           children(entity),
           default()
         ])
       ))
    end
    |> print(entity.module == Blog.User)
  end

  defp attributes(entity) do
    attrs = Enum.reject(entity.attributes, & &1.virtual)

    for attr <- attrs do
      aliases = attr.aliases
      spec = {:ok, attr.kind, attr.column}

      quote do
        def field_spec(f) when f in unquote(aliases), do: unquote(Macro.escape(spec))
      end
    end
  end

  defp parents(entity) do
    for rel <- entity.parents do
      aliases = rel.aliases
      spec = {:ok, :parent, rel.target.name, rel.target.module, rel.column}

      quote do
        def field_spec(f) when f in unquote(aliases), do: unquote(Macro.escape(spec))
      end
    end
  end

  defp children(entity) do
    for rel <- entity.children do
      aliases = rel.aliases
      spec = {:ok, :child, rel.target.name, rel.target.module}

      quote do
        def field_spec(f) when f in unquote(aliases), do: unquote(Macro.escape(spec))
      end
    end
  end

  defp default do
    quote do
      def field_spec(_), do: {:error, :unknown_field}
    end
  end
end
