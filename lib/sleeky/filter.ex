defmodule Sleeky.Filter do
  @moduledoc false

  def filter(model, [:**, ancestor | rest], op, value, q, last_binding) do
    ancestor_path =
      with [] <- model.context().shortest_path(model.name(), ancestor) do
        if rest == [], do: [:id], else: []
      end

    filter(model, ancestor_path ++ rest, op, value, q, last_binding)
  end

  def filter(model, [field], op, value, q, last_binding) do
    case model.field_spec(field) do
      {:error, :unknown_field} ->
        if model.name() == field do
          model.where(q, :id, op, value, on: last_binding)
        else
          nil
        end

      {:ok, _, _column} ->
        model.where(q, field, op, value, on: last_binding)

      {:ok, :child, _, _child_model} ->
        {field, binding} = query_binding(field)
        model.where(q, field, op, value, parent: last_binding, child: binding)

      {:ok, :parent, _, _parent_model, _} ->
        model.where(q, field, op, value, parent: last_binding)
    end
  end

  def filter(model, [field | rest], op, value, q, last_binding) do
    case model.field_spec(field) do
      {:error, :unknown_field} ->
        if model.name() == field do
          filter(model, rest, op, value, q, last_binding)
        else
          nil
        end

      {:ok, _, _column} ->
        model.where(q, field, op, value, on: last_binding)

      {:ok, :child, _, next_model} ->
        {field, binding} = query_binding(field)
        q = model.join(q, field, parent: last_binding, child: binding)
        filter(next_model, rest, op, value, q, binding)

      {:ok, :parent, _, next_model, _} ->
        {field, binding} = query_binding(field)
        q = model.join(q, field, parent: binding, child: last_binding)
        filter(next_model, rest, op, value, q, binding)
    end
  end

  defp query_binding({_, _} = field), do: field
  defp query_binding(field) when is_atom(field), do: {field, field}
end
