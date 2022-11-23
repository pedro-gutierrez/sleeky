defmodule Bee.Entity.Ecto.Changesets do
  @moduledoc false
  import Bee.Inspector

  def ast(entity) do
    fields = fields_changeset(entity)
    default_fields = default_fields_changeset(entity)
    immutable_fields = immutable_fields_changeset(entity)
    max_length = max_length_fields_changeset(entity)
    parent_constraints = parent_constraints_changeset(entity)
    unique_constraints = unique_constraints_changeset(entity)

    [
      insert_changeset(
        fields,
        default_fields,
        max_length,
        parent_constraints,
        unique_constraints
      ),
      update_changeset(
        fields,
        default_fields,
        immutable_fields,
        max_length,
        parent_constraints,
        unique_constraints
      ),
      delete_changeset(entity)
    ]
    |> print()
  end

  defp insert_changeset(
         fields,
         default_fields,
         max_length,
         parent_constraints,
         unique_constraints
       ) do
    quote do
      def insert_changeset(e, attrs) do
        (unquote_splicing(
           flatten([
             fields,
             default_fields,
             max_length,
             parent_constraints,
             unique_constraints
           ])
         ))
      end
    end
  end

  defp update_changeset(
         fields,
         default_fields,
         immutable_fields,
         max_length,
         parent_constraints,
         unique_constraints
       ) do
    quote do
      def update_changeset(e, attrs) do
        (unquote_splicing(
           flatten([
             immutable_fields,
             fields,
             default_fields,
             max_length,
             parent_constraints,
             unique_constraints
           ])
         ))
      end
    end
  end

  defp delete_changeset(entity) do
    quote do
      def delete_changeset(e, attrs) do
        changes = cast(e, %{}, [])

        unquote_splicing(
          flatten([
            children_constraints_changeset(entity)
          ])
        )
      end
    end
  end

  defp fields_changeset(entity) do
    constraint = entity.pk_constraint

    quote do
      changes =
        e
        |> cast(attrs, @all_fields)
        |> validate_required(@required_fields)
        |> unique_constraint(:id, name: unquote(constraint))
    end
  end

  defp default_fields_changeset(entity) do
    attrs = Enum.filter(entity.attributes, & &1.default)

    for attr <- attrs do
      name = attr.name
      default = attr.default

      quote do
        changes =
          case get_field(changes, unquote(name)) do
            nil -> put_change(changes, unquote(name), unquote(default))
            _ -> changes
          end
      end
    end
  end

  defp immutable_fields_changeset(entity) do
    attrs = entity.attributes |> Enum.filter(& &1.immutable) |> names()
    parents = entity.parents |> Enum.filter(& &1.immutable) |> names()

    fields = attrs ++ parents

    if fields == [] do
      nil
    else
      quote do
        attrs = Map.drop(attrs, unquote(attrs ++ parents))
      end
    end
  end

  defp max_length_fields_changeset(entity) do
    attrs = Enum.filter(entity.attributes, &(&1.kind == :string))

    for attr <- attrs do
      name = attr.name

      quote do
        changes =
          validate_length(changes, unquote(name),
            max: 255,
            message: "should be at most 255 characters"
          )
      end
    end
  end

  defp parent_constraints_changeset(entity) do
    for rel <- entity.parents do
      fk = rel.foreign_key
      name = fk.name
      field = fk.field
      message = "referenced #{rel.target.name} does not exist"

      quote do
        changes =
          foreign_key_constraint(changes, unquote(field),
            name: unquote(name),
            message: unquote(message)
          )
      end
    end
  end

  defp children_constraints_changeset(entity) do
    for rel <- entity.children do
      fk = rel.foreign_key
      name = fk.name
      field = fk.field
      message = "attempting to delete an entity of type #{inspect(entity.name)} that has children"

      quote do
        changes =
          foreign_key_constraint(changes, unquote(field),
            name: unquote(name),
            message: unquote(message)
          )
      end
    end
  end

  defp unique_constraints_changeset(entity) do
    for key <- entity.keys do
      field = key.name
      name = key.index

      quote do
        changes = unique_constraint(changes, unquote(field), name: unquote(name))
      end
    end
  end
end
