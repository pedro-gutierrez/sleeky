defmodule Sleeky.Entity.Generator.EctoSchema do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Naming

  @impl true
  def generate(entity, _) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      unquote(primary_key(entity))
      unquote(prefix(entity))

      schema unquote(table_name(entity)) do
        (unquote_splicing(
           List.flatten([
             attributes(entity),
             parents(entity),
             children(entity)
           ])
         ))

        timestamps(type: :utc_datetime_usec)
      end
    end
  end

  defp table_name(entity), do: to_string(entity.plural)

  defp primary_key(entity) do
    pk = entity.primary_key
    column = pk.column_name
    datatype = pk.storage

    quote do
      @primary_key {unquote(column), unquote(datatype), [autogenerate: false]}
    end
  end

  def prefix(entity) do
    prefix = Naming.name(entity.context)

    quote do
      @schema_prefix unquote(prefix)
    end
  end

  defp attributes(entity) do
    attrs =
      entity.attributes
      |> Enum.reject(& &1.primary_key?)

    for attr <- attrs do
      name = attr.name
      type = attr.ecto_type

      case attr.default do
        nil ->
          quote do
            field(unquote(name), unquote(type))
          end

        default ->
          quote do
            field(unquote(name), unquote(type), default: unquote(default))
          end
      end
    end
  end

  defp parents(entity) do
    for %{kind: :parent} = rel <- entity.relations do
      quote do
        Ecto.Schema.belongs_to(
          unquote(rel.name),
          unquote(rel.target.module),
          type: :binary_id,
          foreign_key: unquote(rel.column_name)
        )
      end
    end
  end

  defp children(entity) do
    for %{kind: :child} = rel <- entity.relations do
      inverse = rel.inverse

      quote do
        Ecto.Schema.has_many(
          unquote(rel.name),
          unquote(rel.target.module),
          foreign_key: unquote(inverse.column_name)
        )
      end
    end
  end
end
