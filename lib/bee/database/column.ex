defmodule Bee.Database.Column do
  @moduledoc false
  alias Bee.Database.ColumnOpts
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
      primary_key: attr.name == :id
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

  def encode(col) do
    opts =
      [null: col.null]
      |> maybe_encode_default(col)
      |> maybe_encode_primary_key(col)

    [col.name, col.kind, opts]
  end

  def apply_changes(%__MODULE__{} = col, %ColumnOpts{} = changes) do
    Enum.reduce(changes.opts, col, fn {key, value}, c ->
      Map.put(c, key, value)
    end)
  end

  def diff(%__MODULE__{} = old, %__MODULE__{} = new) do
    changes = ColumnOpts.new(new.name, [])

    Enum.reduce([:kind, :default, :primary_key, :references, :null], changes, fn key, changes ->
      if Map.get(old, key) != Map.get(new, key) do
        opts = Keyword.put(changes.opts, key, Map.get(new, key))
        %{changes | opts: opts}
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

  defp with_primary_key(col, opts) do
    %{col | primary_key: Keyword.get(opts, :primary_key, false)}
  end

  defp maybe_encode_primary_key(opts, col) do
    if col.primary_key do
      Keyword.put(opts, :primary_key, true)
    else
      opts
    end
  end

  defp with_references(col, opts) do
    case opts[:references] do
      nil -> col
      table -> %{col | references: table}
    end
  end
end
