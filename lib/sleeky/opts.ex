defmodule Sleeky.Opts do
  def with_opts(field, nil), do: field

  def with_opts(field, do: {:__block__, _, opts}) do
    with_opts(field, opts)
  end

  def with_opts(field, do: {modifier, _, _}) do
    with_opt(field, modifier)
  end

  def with_opts(field, opts) do
    Enum.reduce(opts, field, &with_opt(&2, &1))
  end

  def with_opt(field, :optional) do
    Map.put(field, :required?, false)
  end

  def with_opt(field, other) do
    Map.put(field, other, true)
  end
end
