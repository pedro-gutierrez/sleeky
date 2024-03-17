defmodule Sleeky.Schema.Definition do
  @moduledoc false

  @doc false
  def entities(definition), do: modules(definition, :entity)

  @doc false
  def enums(definition), do: modules(definition, :enum)

  defp modules(definition, type) do
    definition
    |> Enum.filter(fn {t, _, _} -> t == type end)
    |> Enum.map(fn {_, _, [mod]} -> mod end)
  end
end
