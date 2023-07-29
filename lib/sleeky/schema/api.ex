defmodule Sleeky.Schema.Api do
  @moduledoc false

  @generators [
    Sleeky.Schema.Api.Helpers,
    Sleeky.Schema.Api.Entities
  ]

  import Sleeky.Inspector

  def ast(schema) do
    @generators
    |> Enum.map(& &1.ast(schema))
    |> flatten()
  end
end
