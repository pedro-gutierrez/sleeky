defmodule Sleeky.Model.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_model, metadata) do
    attributes = metadata.attributes
    parents = Enum.filter(metadata.relations, &(&1.kind == :parent))
    fields = Enum.reduce(attributes ++ parents, %{}, &Map.put(&2, &1.name, &1))
    keys = metadata.keys

    quote do
      @attributes unquote(Macro.escape(attributes))
      @parents unquote(Macro.escape(parents))
      @fields unquote(Macro.escape(fields))
      @keys unquote(Macro.escape(keys))

      def name, do: unquote(metadata.name)
      def plural, do: unquote(metadata.plural)
      def table_name, do: unquote(metadata.table_name)
      def context, do: unquote(metadata.context)
      def virtual?, do: unquote(metadata.virtual?)
      def primary_key, do: unquote(Macro.escape(metadata.primary_key))

      def parents, do: @parents
      def attributes, do: @attributes
      def keys, do: @keys
      def fields, do: @fields

      def field(name) do
        case Map.get(@fields, name) do
          nil -> {:error, :field_not_found}
          field -> {:ok, field}
        end
      end
    end
  end
end
