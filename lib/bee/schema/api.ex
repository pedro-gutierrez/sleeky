defmodule Bee.Schema.Api do
  @moduledoc false

  @generators [
    Bee.Schema.Api.Helpers,
    Bee.Schema.Api.Entities
  ]

  import Bee.Inspector

  def ast(schema) do
    @generators
    |> Enum.map(& &1.ast(schema))
    |> flatten()
  end
end
