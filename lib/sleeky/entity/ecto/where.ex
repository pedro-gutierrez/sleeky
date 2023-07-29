defmodule Sleeky.Entity.Ecto.Where do
  @moduledoc false

  def ast(entity) do
    [
      default_where_opts_function(),
      parents_where_functions(entity),
      children_where_functions(entity),
      attributes_where_functions(entity),
      do_where_functions()
    ]
  end

  defp default_where_opts_function do
    quote do
      def where(q, field, op, value, opts \\ [])
    end
  end

  defp parents_where_functions(entity) do
    for rel <- entity.parents do
      [
        parent_eq_nil_where_function(rel),
        parent_eq_where_function(rel),
        parent_neq_where_function(rel),
        parent_in_where_function(rel)
      ]
    end
  end

  defp children_where_functions(entity) do
    for rel <- entity.children do
      quote do
        def where(q, unquote(rel.name), op, value, opts) do
          child_binding = Keyword.get(opts, :child, unquote(rel.name))

          q
          |> __MODULE__.join(unquote(rel.name), opts)
          |> do_where(:id, op, value, child_binding)
        end
      end
    end
  end

  defp attributes_where_functions(entity) do
    for attr <- entity.attributes do
      quote do
        def where(q, unquote(attr.name), op, value, opts) do
          binding = Keyword.get(opts, :on, unquote(entity.name))
          do_where(q, unquote(attr.column), op, value, binding)
        end
      end
    end
  end

  defp parent_eq_nil_where_function(rel) do
    quote do
      def where(q, unquote(rel.name), :eq, nil, opts) do
        binding = Keyword.get(opts, :parent, unquote(rel.name))

        where(q, [{^binding, e}], is_nil(e.unquote(rel.column)))
      end
    end
  end

  defp parent_eq_where_function(rel) do
    quote do
      def where(q, unquote(rel.name), :eq, id, opts) do
        binding = Keyword.get(opts, :parent, unquote(rel.name))

        where(q, [{^binding, e}], e.unquote(rel.column) == ^id)
      end
    end
  end

  defp parent_neq_where_function(rel) do
    quote do
      def where(q, unquote(rel.name), :neq, id, opts) do
        binding = Keyword.get(opts, :parent, unquote(rel.name))

        where(q, [{^binding, e}], e.unquote(rel.column) != ^id)
      end
    end
  end

  defp parent_in_where_function(rel) do
    quote do
      def where(q, unquote(rel.name), :in, ids, opts) when is_list(ids) do
        binding = Keyword.get(opts, :parent, unquote(rel.name))

        where(q, [{^binding, e}], e.unquote(rel.column) in ^ids)
      end
    end
  end

  defp do_where_functions do
    [
      quote do
        defp do_where(q, column_name, :neq, nil, binding) do
          where(q, [{^binding, e}], not is_nil(field(e, ^column_name)))
        end
      end,
      quote do
        defp do_where(q, column_name, _, nil, binding) do
          where(q, [{^binding, e}], is_nil(field(e, ^column_name)))
        end
      end,
      quote do
        defp do_where(q, column_name, :eq, value, binding) do
          where(q, [{^binding, e}], field(e, ^column_name) == ^value)
        end
      end,
      quote do
        defp do_where(q, column_name, :neq, value, binding) do
          where(q, [{^binding, e}], field(e, ^column_name) != ^value)
        end
      end,
      quote do
        defp do_where(q, column_name, :gte, value, binding) do
          where(q, [{^binding, e}], field(e, ^column_name) >= ^value)
        end
      end,
      quote do
        defp do_where(q, column_name, :gt, value, binding) do
          where(q, [{^binding, e}], field(e, ^column_name) > ^value)
        end
      end,
      quote do
        defp do_where(q, column_name, :lte, value, binding) do
          where(q, [{^binding, e}], field(e, ^column_name) <= ^value)
        end
      end,
      quote do
        defp do_where(q, column_name, :lt, value, binding) do
          where(q, [{^binding, e}], field(e, ^column_name) < ^value)
        end
      end,
      quote do
        defp do_where(q, column_name, :in, values, binding) when is_list(values) do
          where(q, [{^binding, e}], field(e, ^column_name) in ^values)
        end
      end
    ]
  end
end
