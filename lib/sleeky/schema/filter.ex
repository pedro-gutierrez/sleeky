defmodule Sleeky.Schema.Filter do
  @moduledoc false

  def ast(_schema) do
    [
      filter_functions(),
      query_binding_functions()
    ]
  end

  defp filter_functions do
    [
      filter_ancestor_function(),
      filter_trailing_field_function(),
      filter_field_function()
    ]
  end

  defp filter_ancestor_function do
    quote do
      def filter(entity, [:**, ancestor | rest], op, value, q, last_binding) do
        ancestor_path =
          with [] <- nearest_path(entity, ancestor) do
            if rest == [], do: [:id], else: []
          end

        filter(entity, ancestor_path ++ rest, op, value, q, last_binding)
      end
    end
  end

  def filter_trailing_field_function do
    quote do
      def filter(entity, [field], op, value, q, last_binding) do
        case entity.field_spec(field) do
          {:error, :unknown_field} ->
            if entity.name() == field do
              entity.where(q, :id, op, value, on: last_binding)
            else
              nil
            end

          {:ok, _, _column} ->
            entity.where(q, field, op, value, on: last_binding)

          {:ok, :child, _, _child_entity} ->
            {field, binding} = query_binding(field)
            entity.where(q, field, op, value, parent: last_binding, child: binding)

          {:ok, :parent, _, _parent_entity, _} ->
            entity.where(q, field, op, value, parent: last_binding)
        end
      end
    end
  end

  def filter_field_function do
    quote do
      def filter(entity, [field | rest], op, value, q, last_binding) do
        case entity.field_spec(field) do
          {:error, :unknown_field} ->
            if entity.name() == field do
              filter(entity, rest, op, value, q, last_binding)
            else
              nil
            end

          {:ok, _, _column} ->
            entity.where(q, field, op, value, on: last_binding)

          {:ok, :child, _, next_entity} ->
            {field, binding} = query_binding(field)
            q = entity.join(q, field, parent: last_binding, child: binding)
            filter(next_entity, rest, op, value, q, binding)

          {:ok, :parent, _, next_entity, _} ->
            {field, binding} = query_binding(field)
            q = entity.join(q, field, parent: binding, child: last_binding)
            filter(next_entity, rest, op, value, q, binding)
        end
      end
    end
  end

  defp query_binding_functions do
    [
      quote do
        defp query_binding({_, _} = field), do: field
      end,
      quote do
        defp query_binding(field) when is_atom(field), do: {field, field}
      end
    ]
  end
end
