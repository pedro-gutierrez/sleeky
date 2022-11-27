defmodule Bee.Database.ColumnOpts do
  @moduledoc false

  defstruct [:name, opts: []]

  def new(name, opts) do
    __MODULE__
    |> struct(name: name, opts: opts)
  end

  def decode([name, kind, opts]) do
    opts = Keyword.put(opts, :kind, kind)
    new(name, opts)
  end

  def decode([name, {:references, _, [target, opts]}]) do
    opts = Keyword.put(opts, :references, target)
    new(name, opts)
  end

  def empty?(%__MODULE__{} = changes), do: Enum.empty?(changes.opts)
end
