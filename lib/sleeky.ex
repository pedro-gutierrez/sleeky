defmodule Sleeky do
  @moduledoc """
  The `Sleeky` module aggregates and provides common utility functions for handling DSLs (Domain Specific Languages)
  within the Sleeky application. It collects various DSL modules and offers functions to manage their local functions
  and tags.
  """

  @dsls [
    Sleeky.Scopes.Dsl,
    Sleeky.Feature.Dsl,
    Sleeky.Model.Dsl,
    Sleeky.Api.Dsl,
    Sleeky.Endpoint.Dsl,
    Sleeky.Ui.Dsl,
    Sleeky.Ui.View.Dsl,
    Sleeky.Ui.Namespace.Dsl,
    Sleeky.Ui.Route.Dsl
  ]

  @doc """
  Returns a sorted list of local functions without parentheses from all the DSL modules.
  """
  def locals_without_parens,
    do: @dsls |> Enum.flat_map(& &1.locals_without_parens()) |> Enum.uniq() |> Enum.sort()

  @doc """
  Returns a flat list of tags from all the DSL modules.
  """
  def tags, do: Enum.flat_map(@dsls, & &1.tags())
end
