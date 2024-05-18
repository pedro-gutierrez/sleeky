defmodule Sleeky.Model.Generator.FieldSpec do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_caller, model) do
    [
      attributes(model),
      parents(model),
      children(model),
      default()
    ]
  end

  defp attributes(model) do
    attrs = Enum.reject(model.attributes, & &1.virtual?)

    for attr <- attrs do
      aliases = attr.aliases
      spec = {:ok, attr.kind, attr.column_name}

      quote do
        def field_spec(f) when f in unquote(aliases), do: unquote(Macro.escape(spec))
      end
    end
  end

  defp parents(model) do
    for rel when rel.kind == :parent <- model.relations do
      aliases = rel.aliases
      spec = {:ok, :parent, rel.target.name, rel.target.module, rel.column_name}

      quote do
        def field_spec(f) when f in unquote(aliases), do: unquote(Macro.escape(spec))
      end
    end
  end

  defp children(model) do
    for rel when rel.kind == :child <- model.relations do
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
