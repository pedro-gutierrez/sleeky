defmodule Bee.Migrations.Column do
  @moduledoc false

  defstruct [
    :name,
    :kind,
    :default,
    pkey: false,
    null: false
  ]

  def all_for_entity(entity) do
    from_attributes(entity) ++ from_parents(entity)
  end

  defp from_attributes(entity) do
    attrs = Enum.reject(entity.attributes, &(&1.virtual || &1.timestamp))

    for attr <- attrs do
      %__MODULE__{
        name: attr.column,
        kind: attr.storage,
        null: !attr.required,
        default: attr.default,
        pkey: attr.name == :id
      }
    end
  end

  defp from_parents(entity) do
    for rel <- entity.parents do
      %__MODULE__{
        name: rel.column,
        kind: :uuid,
        null: !rel.required
      }
    end
  end

  def encode_args(%__MODULE__{} = col) do
    opts =
      [null: col.null]
      |> with_default(col)
      |> with_pkey(col)

    [col.name, col.kind, opts]
  end

  defp with_default(opts, col) do
    case col.default do
      nil -> opts
      default -> Keyword.put(opts, :default, default)
    end
  end

  defp with_pkey(opts, col) do
    case col.pkey do
      false -> opts
      true -> Keyword.put(opts, :primary_key, true)
    end
  end
end
