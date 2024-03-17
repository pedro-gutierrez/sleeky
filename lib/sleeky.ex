defmodule Sleeky do
  @moduledoc false

  @dsls [Sleeky.Context.Dsl, Sleeky.Model.Dsl, Sleeky.Ui.Dsl, Sleeky.Ui.View.Dsl]

  @doc false
  def locals_without_parens,
    do: @dsls |> Enum.flat_map(& &1.locals_without_parens()) |> Enum.sort()

  @doc false
  def tags, do: Enum.flat_map(@dsls, & &1.tags())
end
