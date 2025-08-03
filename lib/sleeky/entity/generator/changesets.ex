defmodule Sleeky.Entity.Generator.Changesets do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(entity, _) do
    [
      insert_changeset(entity),
      update_changeset(entity),
      delete_changeset(entity)
    ]
  end

  defp insert_changeset(entity) do
    primary_key_constraint = String.to_atom("#{entity.plural}_pkey")
    unique_constraints = unique_constraints(entity)
    inclusion_validations = inclusion_validations(entity)
    parents_contraints = parents_constraints(entity)
    uuid_validations = uuid_validations(entity)

    quote do
      def insert_changeset(%__MODULE__{} = entity, attrs) do
        changes =
          entity
          |> cast(attrs, @fields_on_insert)
          |> validate_required(@required_fields)
          |> unique_constraint([:id], name: unquote(primary_key_constraint))

        unquote_splicing(uuid_validations)
        unquote_splicing(unique_constraints)
        unquote_splicing(inclusion_validations)
        unquote_splicing(parents_contraints)
      end
    end
  end

  defp update_changeset(entity) do
    inclusion_validations = inclusion_validations(entity)
    parents_contraints = parents_constraints(entity)
    uuid_validations = uuid_validations(entity)

    quote do
      def update_changeset(%__MODULE__{} = entity, attrs) do
        changes =
          entity
          |> cast(attrs, @fields_on_update)
          |> validate_required(@required_fields)

        unquote_splicing(uuid_validations)
        unquote_splicing(inclusion_validations)
        unquote_splicing(parents_contraints)
      end
    end
  end

  defp delete_changeset(entity) do
    children_constraints = children_constraints(entity)

    quote do
      def delete_changeset(%__MODULE__{} = entity) do
        changes = cast(entity, %{}, [])
        unquote_splicing(children_constraints)
      end
    end
  end

  defp unique_constraints(entity) do
    for %{unique?: true} = key <- entity.keys do
      column_names = Enum.map(key.fields, & &1.column_name)
      constraint_name_parts = [entity.table_name] ++ column_names ++ ["idx"]
      constraint_name = constraint_name_parts |> Enum.join("_") |> String.to_atom()
      field_names = Enum.map(key.fields, & &1.name)

      quote do
        changes = unique_constraint(changes, unquote(field_names), name: unquote(constraint_name))
      end
    end
  end

  defp children_constraints(entity) do
    for %{kind: :child} = rel <- entity.relations do
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

  defp parents_constraints(entity) do
    for %{kind: :parent} = rel <- entity.relations do
      message = "does not exist"

      quote do
        changes =
          foreign_key_constraint(changes, unquote(rel.column_name),
            name: unquote(rel.foreign_key_name),
            message: unquote(message)
          )
      end
    end
  end

  defp inclusion_validations(entity) do
    for %{name: name, in: allowed_values} when allowed_values != [] <- entity.attributes do
      quote do
        changes = validate_inclusion(changes, unquote(name), unquote(allowed_values))
      end
    end
  end

  defp uuid_validations(entity) do
    for %{name: name, ecto_type: :binary_id} <- entity.attributes do
      quote do
        changes = validate_uuid(changes, unquote(name))
      end
    end
  end
end
