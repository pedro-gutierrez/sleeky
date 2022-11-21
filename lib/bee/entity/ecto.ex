defmodule Bee.Entity.Ecto do
  @moduledoc false
  import Bee.Inspector
  alias Bee.Entity.Relation

  def ast(entity) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: false}
      @timestamps_opts [type: :utc_datetime]

      unquote_splicing(
        flatten([
          fields_attributes(entity),
          ecto_schema(entity),
          changesets(entity),
          add_default_if_missing()
        ])
      )
    end
    |> print(entity.module == Blog.Comment)
  end

  defp fields_attributes(entity) do
    [
      required_fields_attribute(entity),
      optional_fields_attribute(entity),
      computed_fields_attribute(entity),
      all_fields_attribute()
    ]
  end

  defp required_fields_attribute(entity) do
    attrs = entity.attributes |> Enum.filter(& &1.required) |> names()
    parents = entity.parents |> Enum.filter(& &1.required) |> columns()

    quote do
      @required_fields unquote(attrs ++ parents)
    end
  end

  defp optional_fields_attribute(entity) do
    attrs = entity.attributes |> Enum.filter(&(!&1.required)) |> names()
    parents = entity.parents |> Enum.filter(&(!&1.required)) |> columns()

    quote do
      @optional_fields unquote(attrs ++ parents)
    end
  end

  defp computed_fields_attribute(entity) do
    attrs = entity.attributes |> Enum.filter(& &1.computed) |> names()
    parents = entity.parents |> Enum.filter(& &1.computed) |> columns()

    quote do
      @computed_fields unquote(attrs ++ parents)
    end
  end

  defp all_fields_attribute do
    quote do
      @all_fields @required_fields ++ @optional_fields
    end
  end

  defp ecto_schema(entity) do
    source = to_string(entity.plural)

    quote do
      schema unquote(source) do
        (unquote_splicing(
           flatten([
             ecto_schema_attributes(entity),
             ecto_schema_parents(entity),
             ecto_schema_children(entity),
             ecto_schema_timestamps()
           ])
         ))
      end
    end
  end

  defp ecto_schema_timestamps do
    quote do
      timestamps()
    end
  end

  defp ecto_schema_attributes(entity) do
    for attr <- Enum.filter(entity.attributes, &(!&1.virtual && &1.name != :id)) do
      name = attr.name
      kind = attr.kind

      case attr.default do
        nil ->
          quote do
            field(unquote(name), unquote(kind))
          end

        default ->
          quote do
            field(unquote(name), unquote(kind), default: unquote(default))
          end
      end
    end
  end

  defp ecto_schema_parents(entity) do
    for rel <- entity.parents do
      quote do
        belongs_to(
          unquote(rel.name),
          unquote(rel.target.module),
          type: :binary_id,
          foreign_key: unquote(rel.column)
        )
      end
    end
  end

  defp ecto_schema_children(entity) do
    for rel <- entity.children do
      inverse = Relation.inverse(rel)

      quote do
        has_many(
          unquote(rel.name),
          unquote(rel.target.module),
          foreign_key: unquote(inverse.column)
        )
      end
    end
  end

  defp changesets(entity) do
    fields = fields_changeset(entity)
    default_fields = default_fields_changeset(entity)
    immutable_fields = immutable_fields_changeset(entity)
    max_length = max_length_fields_changeset(entity)
    foreign_keys = foreign_key_constraints_changeset(entity)

    [
      insert_changeset(fields, default_fields, max_length, foreign_keys),
      update_changeset(fields, default_fields, immutable_fields, max_length, foreign_keys),
      delete_changeset(entity)
    ]
  end

  defp insert_changeset(fields, default_fields, max_length, foreign_keys) do
    quote do
      def insert_changeset(e, attrs) do
        (unquote_splicing(
           flatten([
             fields,
             default_fields,
             max_length,
             foreign_keys
           ])
         ))
      end
    end
  end

  defp update_changeset(fields, default_fields, immutable_fields, max_length, foreign_keys) do
    quote do
      def update_changeset(e, attrs) do
        (unquote_splicing(
           flatten([
             immutable_fields,
             fields,
             default_fields,
             max_length,
             foreign_keys
           ])
         ))
      end
    end
  end

  defp delete_changeset(_entity) do
    quote do
      def delete_changeset(e, attrs) do
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
        changes = add_default_if_missing(changes, unquote(name), unquote(default))
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

  defp add_default_if_missing do
    quote do
      defp add_default_if_missing(changeset, attr, value) do
        case get_field(changeset, attr) do
          nil -> put_change(changeset, attr, value)
          _ -> changeset
        end
      end
    end
  end

  defp max_length_fields_changeset(entity) do
    attrs = Enum.filter(entity.attributes, &(&1.kind == :string && !&1.storage == :text))

    for attr <- attrs do
      name = attr.name

      quote do
        changes =
          changes
          |> validate_length(unquote(name), max: 255, message: "should be at most 255 characters")
      end
    end
  end

  defp foreign_key_constraints_changeset(entity) do
    for rel <- entity.parents do
      fk = rel.foreign_key
      name = fk.name
      field = fk.field
      message = "referenced #{rel.target.name} does not exist"

      quote do
        changes =
          changes
          |> foreign_key_constraint(unquote(field), name: unquote(name), message: unquote(message))
      end
    end
  end
end
