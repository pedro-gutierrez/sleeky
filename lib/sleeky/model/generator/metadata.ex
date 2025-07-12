defmodule Sleeky.Model.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(model, _) do
    attributes = model.attributes
    relations = model.relations
    parents = Enum.filter(relations, &(&1.kind == :parent))
    children = Enum.filter(relations, &(&1.kind == :child))
    fields = Enum.reduce(attributes ++ relations, %{}, &Map.put(&2, &1.name, &1))
    string_fields = for {name, field} <- fields, into: %{}, do: {to_string(name), field}

    actions = model.actions
    keys = model.keys

    parent_field_names = Enum.map(parents, & &1.name)
    attribute_field_names = Enum.map(attributes, & &1.name)
    field_names = attribute_field_names ++ parent_field_names

    quote do
      @repo unquote(model.repo)
      def repo, do: @repo

      @attributes unquote(Macro.escape(attributes))
      @parents unquote(Macro.escape(parents))
      @attribute_field_names unquote(attribute_field_names)
      @parent_field_names unquote(parent_field_names)
      @field_names unquote(field_names)
      @children unquote(Macro.escape(children))
      @fields unquote(Macro.escape(fields))
      @string_fields unquote(Macro.escape(string_fields))
      @keys unquote(Macro.escape(keys))
      @actions unquote(Macro.escape(actions))

      def domain, do: unquote(model.domain)
      def name, do: unquote(model.name)
      def plural, do: unquote(model.plural)
      def table_name, do: unquote(model.table_name)
      def virtual?, do: unquote(model.virtual?)
      def primary_key, do: unquote(Macro.escape(model.primary_key))

      def parents, do: @parents
      def children, do: @children
      def attributes, do: @attributes
      def keys, do: @keys
      def fields, do: @fields
      def actions, do: @actions

      def parent_field_names, do: @parent_field_names
      def attribute_field_names, do: @attribute_field_names
      def field_names, do: @field_names

      def field(name) when is_atom(name) do
        case Map.get(@fields, name) do
          nil -> {:error, :field_not_found}
          field -> {:ok, field}
        end
      end

      def field(name) when is_binary(name) do
        case Map.get(@string_fields, name) do
          nil -> {:error, :field_not_found}
          field -> {:ok, field}
        end
      end
    end
  end
end
