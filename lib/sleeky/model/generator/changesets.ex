defmodule Sleeky.Model.Generator.Changesets do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(model, _) do
    [
      validate_changeset(model),
      insert_changeset(model),
      update_changeset(model),
      delete_changeset(model)
    ]
  end

  defp validate_changeset(model) do
    inclusion_validations = inclusion_validations(model)
    uuid_validations = uuid_validations(model)

    quote do
      def validate_changeset(attrs) do
        changes =
          %__MODULE__{}
          |> cast(attrs, @fields_on_insert)
          |> validate_required(@required_fields)

        unquote_splicing(uuid_validations)
        unquote_splicing(inclusion_validations)
      end
    end
  end

  defp insert_changeset(model) do
    primary_key_constraint = String.to_atom("#{model.plural}_pkey")
    unique_constraints = unique_constraints(model)
    inclusion_validations = inclusion_validations(model)
    parents_contraints = parents_constraints(model)
    uuid_validations = uuid_validations(model)

    quote do
      def insert_changeset(%__MODULE__{} = model, attrs) do
        changes =
          model
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

  defp update_changeset(model) do
    inclusion_validations = inclusion_validations(model)
    parents_contraints = parents_constraints(model)
    uuid_validations = uuid_validations(model)

    quote do
      def update_changeset(%__MODULE__{} = model, attrs) do
        changes =
          model
          |> cast(attrs, @fields_on_update)
          |> validate_required(@required_fields)

        unquote_splicing(uuid_validations)
        unquote_splicing(inclusion_validations)
        unquote_splicing(parents_contraints)
      end
    end
  end

  defp delete_changeset(model) do
    children_constraints = children_constraints(model)

    quote do
      def delete_changeset(%__MODULE__{} = model) do
        changes = cast(model, %{}, [])
        unquote_splicing(children_constraints)
      end
    end
  end

  defp unique_constraints(model) do
    for %{unique?: true} = key <- model.keys do
      column_names = Enum.map(key.fields, & &1.column_name)
      constraint_name_parts = [model.table_name] ++ column_names ++ ["idx"]
      constraint_name = constraint_name_parts |> Enum.join("_") |> String.to_atom()
      field_names = Enum.map(key.fields, & &1.name)

      quote do
        changes = unique_constraint(changes, unquote(field_names), name: unquote(constraint_name))
      end
    end
  end

  defp children_constraints(model) do
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

  defp parents_constraints(model) do
    for %{kind: :parent} = rel <- model.relations do
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

  defp inclusion_validations(model) do
    for %{name: name, in: allowed_values} when allowed_values != [] <- model.attributes do
      quote do
        changes = validate_inclusion(changes, unquote(name), unquote(allowed_values))
      end
    end
  end

  defp uuid_validations(model) do
    for %{name: name, ecto_type: :binary_id} <- model.attributes do
      quote do
        changes = validate_uuid(changes, unquote(name))
      end
    end
  end
end
