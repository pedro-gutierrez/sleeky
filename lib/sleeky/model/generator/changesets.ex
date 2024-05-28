defmodule Sleeky.Model.Generator.Changesets do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Ast

  @impl true
  def generate(_, model) do
    [
      insert_changeset(model),
      inlined_insert_changeset(model),
      update_changeset(model),
      delete_changeset(model)
    ]
  end

  defp insert_changeset(model) do
    changes = var(:changes)
    cast_inlined_children = cast_inlined_children(model)

    quote do
      def insert_changeset(%__MODULE__{} = model, attrs, opts \\ []) do
        required_fields = Keyword.get(opts, :required_fields, @fields_on_insert)

        unquote(changes) = cast(model, attrs, required_fields)
        unquote(cast_inlined_children)
        validate_required(unquote(changes), required_fields)
      end
    end
  end

  defp inlined_insert_changeset(model) do
    parents_columns = for %{kind: :parent} = rel <- model.relations, do: rel.column_name

    quote do
      def inlined_insert_changeset(%__MODULE__{} = model, attrs) do
        insert_changeset(model, attrs,
          required_fields: @fields_on_insert -- unquote(parents_columns)
        )
      end
    end
  end

  defp cast_inlined_children(model) do
    changes = var(:changes)
    children = for %{kind: :child} = rel <- model.relations, do: {rel.name, rel.target.module}

    quote do
      unquote(changes) =
        Enum.reduce(unquote(children), unquote(changes), fn {field, model}, acc ->
          cast_assoc(unquote(changes), field, with: &model.inlined_insert_changeset/2)
        end)
    end
  end

  defp update_changeset(_model) do
    quote do
      def update_changeset(%__MODULE__{} = model, attrs) do
        model
        |> cast(attrs, @fields_on_update)
        |> validate_required(@required_fields)
      end
    end
  end

  defp delete_changeset(model) do
    changes =
      flattened([
        children_constraints_changeset(model)
      ])

    quote do
      def delete_changeset(%__MODULE__{} = model) do
        changes = cast(model, %{}, [])
        unquote_splicing(changes)
      end
    end
  end

  defp children_constraints_changeset(model) do
    for %{kind: :child} = rel <- model.relations do
      message = "has children"
      inverse = rel.inverse

      quote do
        changes =
          foreign_key_constraint(changes, unquote(inverse.column_name),
            name: unquote(inverse.foreign_key_name),
            message: unquote(message)
          )
      end
    end
  end
end
