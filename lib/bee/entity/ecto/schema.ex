defmodule Bee.Entity.Ecto.Schema do
  @moduledoc false
  import Bee.Inspector
  alias Bee.Entity.Relation

  def ast(entity) do
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
    |> print()
  end

  defp ecto_schema_timestamps do
    quote do
      timestamps()
    end
  end

  defp ecto_schema_attributes(entity) do
    attrs = Enum.reject(entity.attributes, &(&1.virtual || &1.implied))

    for attr <- attrs do
      name = attr.name
      storage = attr.storage

      case attr.default do
        nil ->
          quote do
            field(unquote(name), unquote(storage))
          end

        default ->
          quote do
            field(unquote(name), unquote(storage), default: unquote(default))
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
end
