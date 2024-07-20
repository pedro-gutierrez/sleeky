defmodule Sleeky.Template do
  @moduledoc """
  Simple templating using Solid
  """

  def render!(text, vars, opts \\ [])

  def render!(text, vars, opts) when is_binary(text) do
    text
    |> Solid.parse!()
    |> render!(vars, opts)
  end

  def render!(template, vars, opts) do
    vars = string_keys(vars)

    template |> Solid.render!(vars, opts) |> to_string()
  end

  defp string_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} ->
      {to_string(key), string_keys(value)}
    end)
    |> Enum.into(%{})
  end

  defp string_keys(items) when is_list(items), do: Enum.map(items, &string_keys/1)
  defp string_keys(other), do: other
end
