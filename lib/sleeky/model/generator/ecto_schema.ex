defmodule Sleeky.Model.Generator.EctoSchema do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Naming

  @impl true
  def generate(model, _) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      unquote(primary_key(model))
      unquote(prefix(model))

      schema unquote(table_name(model)) do
        (unquote_splicing(
           List.flatten([
             attributes(model),
             parents(model),
             children(model)
           ])
         ))

        timestamps(type: :utc_datetime_usec)
      end
    end
  end

  defp table_name(model), do: to_string(model.plural)

  defp primary_key(model) do
    pk = model.primary_key
    column = pk.column_name
    datatype = pk.storage

    quote do
      @primary_key {unquote(column), unquote(datatype), [autogenerate: false]}
    end
  end

  def prefix(model) do
    prefix = Naming.name(model.feature)

    quote do
      @schema_prefix unquote(prefix)
    end
  end

  defp attributes(model) do
    attrs =
      model.attributes
      |> Enum.reject(&(&1.primary_key? || &1.name in [:inserted_at, :updated_at]))

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

  defp parents(model) do
    for %{kind: :parent} = rel <- model.relations do
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

  defp children(model) do
    for %{kind: :child} = rel <- model.relations do
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
