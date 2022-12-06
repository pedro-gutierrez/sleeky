defmodule Bee.Database.Column do
  @moduledoc false
  alias Bee.Database.ColumnChanges
  alias Bee.Entity.Attribute
  alias Bee.Entity.Relation

  defstruct [
    :name,
    :kind,
    :default,
    primary_key: false,
    references: nil,
    null: false
  ]

  def new(name, kind, opts) do
    __MODULE__
    |> struct(name: name, kind: kind)
    |> with_primary_key(opts)
    |> with_references(opts)
    |> with_null(opts)
    |> with_default(opts)
    |> with_enum_kind(opts)
  end

  def new(name) when is_atom(name) do
    new(name, nil, [])
  end

  def new([name, kind, opts]) do
    new(name, kind, opts)
  end

  def new(%Attribute{} = attr) do
    new(attr.column, attr.storage,
      null: !attr.required,
      default: attr.default,
      primary_key: attr.name == :id,
      enum: attr.enum
    )
  end

  def new(%Relation{kind: :parent} = rel) do
    new(rel.column, :uuid,
      null: !rel.required,
      references: rel.target.table
    )
  end

  def decode(columns) when is_list(columns) do
    columns
    |> Enum.map(&decode/1)
    |> Enum.reject(&is_nil/1)
  end

  def decode({:add, _, [name, kind, opts]}), do: new(name, kind, opts)

  def decode({:timestamps, _, _}), do: nil

  def encode(%__MODULE__{} = col) do
    opts =
      []
      |> maybe_encode_null(col)
      |> maybe_encode_default(col)
      |> maybe_encode_primary_key(col)

    [col.name, col.kind, opts]
  end

  def encode(%ColumnChanges{} = changes) do
    opts =
      []
      |> maybe_encode_null(changes)
      |> maybe_encode_default(changes)
      |> maybe_encode_primary_key(changes)

    [changes.name, changes.kind, opts]
  end

  def apply_changes(%__MODULE__{} = col, %ColumnChanges{} = changes) do
    ColumnChanges.tracked()
    |> Enum.reduce(col, fn key, c ->
      case Map.get(changes, key) do
        nil -> c
        value -> Map.put(c, key, value)
      end
    end)
  end

  def diff(%__MODULE__{} = old, %__MODULE__{} = new) do
    changes = ColumnChanges.new(new.name)

    ColumnChanges.tracked()
    |> Enum.reduce(changes, fn key, changes ->
      if Map.get(old, key) != Map.get(new, key) do
        value = Map.get(new, key)
        Map.put(changes, key, value)
      else
        changes
      end
    end)
  end

  defp with_null(col, opts) do
    %{col | null: Keyword.get(opts, :null, false)}
  end

  defp with_default(col, opts) do
    case opts[:default] do
      nil -> col
      default -> %{col | default: default}
    end
  end

  defp maybe_encode_default(opts, col) do
    if col.default do
      Keyword.put(opts, :default, col.default)
    else
      opts
    end
  end

  defp maybe_encode_null(opts, col) do
    if col.null do
      Keyword.put(opts, :null, col.null)
    else
      opts
    end
  end

  defp maybe_encode_primary_key(opts, col) do
    if col.primary_key do
      Keyword.put(opts, :primary_key, true)
    else
      opts
    end
  end

  defp with_primary_key(col, opts) do
    %{col | primary_key: Keyword.get(opts, :primary_key, false)}
  end

  defp with_references(col, opts) do
    case opts[:references] do
      nil -> col
      table -> %{col | references: table}
    end
  end

  defp with_enum_kind(col, opts) do
    case opts[:enum] do
      nil -> col
      enum -> %{col | kind: enum}
    end
  end
end
