defmodule Sleeky.Dsl do
  @moduledoc false

  @doc false
  def locals_without_parens do
    Sleeky.Entity.Dsl.locals_without_parens() ++
      Sleeky.Ui.Dsl.locals_without_parens()
  end
end
