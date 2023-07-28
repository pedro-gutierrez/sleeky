defmodule Sleeki.Database.ColumnChanges do
  @moduledoc false

  defstruct [
    :name,
    :kind,
    :default,
    :primary_key,
    :references,
    :null
  ]

  def tracked, do: [:kind, :default, :primary_key, :references, :null]

  def new(name, opts \\ []) do
    opts = Keyword.put(opts, :name, name)
    struct(__MODULE__, opts)
  end

  def decode([name, kind, opts]) do
    opts = Keyword.put(opts, :kind, kind)
    new(name, opts)
  end

  def decode([name, {:references, _, [target, opts]}]) do
    opts = Keyword.put(opts, :references, target)
    new(name, opts)
  end

  def empty?(%__MODULE__{} = changes) do
    tracked()
    |> Enum.all?(fn key ->
      changes |> Map.get(key) |> is_nil()
    end)
  end
end
