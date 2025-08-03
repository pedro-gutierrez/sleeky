defmodule Sleeky.Entity.Generator.Join do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(entity, _) do
    [
      header_join_function(),
      join_parents_functions(entity),
      join_children_functions(entity),
      default_join_function()
    ]
  end

  defp header_join_function do
    quote do
      def join(q, rel, opts \\ [])
    end
  end

  defp join_parents_functions(entity) do
    for %{kind: :parent} = rel <- entity.relations do
      column_name = rel.column_name
      target_entity = rel.target.module

      quote do
        def join(q, unquote(rel.name), opts) do
          parent_binding = Keyword.get(opts, :parent, unquote(rel.name))
          child_binding = Keyword.get(opts, :child, unquote(entity.name))

          if has_named_binding?(q, parent_binding) do
            join(q, :inner, [{^child_binding, child}], parent in unquote(target_entity),
              on: parent.id == child.unquote(column_name)
            )
          else
            join(q, :inner, [{^child_binding, child}], parent in unquote(target_entity),
              as: ^parent_binding,
              on: parent.id == child.unquote(column_name)
            )
          end
        end
      end
    end
  end

  def join_children_functions(entity) do
    for %{kind: :child} = rel <- entity.relations do
      target_entity = rel.target.module
      inverse = rel.inverse
      column_name = inverse.column_name

      quote do
        def join(q, unquote(rel.name), opts) do
          parent_binding = Keyword.get(opts, :parent, unquote(inverse.name))
          child_binding = Keyword.get(opts, :child, unquote(rel.name))

          if has_named_binding?(q, child_binding) do
            join(q, :inner, [{^parent_binding, parent}], child in unquote(target_entity),
              on: parent.id == child.unquote(column_name)
            )
          else
            join(q, :inner, [{^parent_binding, parent}], child in unquote(target_entity),
              as: ^child_binding,
              on: parent.id == child.unquote(column_name)
            )
          end
        end
      end
    end
  end

  defp default_join_function do
    quote do
      def join(q, other, _) do
        raise "Cannot join #{inspect(__MODULE__)} on #{inspect(other)}. No such relation."
      end
    end
  end
end
