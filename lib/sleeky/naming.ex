defmodule Sleeky.Naming do
  @moduledoc """
  Naming conventions
  """

  @doc false
  def name(model) do
    model
    |> last_module()
    |> Macro.underscore()
    |> String.to_atom()
  end

  @doc false
  def plural(model) do
    model
    |> last_module()
    |> to_string()
    |> Macro.underscore()
    |> Inflex.pluralize()
    |> String.to_atom()
  end

  defp last_module(name) do
    name
    |> Module.split()
    |> List.last()
  end

  @doc false
  def module(context, name) do
    name = name |> to_string() |> Macro.camelize()
    Module.concat(context, name)
  end
end
