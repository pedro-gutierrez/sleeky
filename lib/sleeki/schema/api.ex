defmodule Sleeki.Schema.Api do
  @moduledoc false

  @generators [
    Sleeki.Schema.Api.Helpers,
    Sleeki.Schema.Api.Entities
  ]

  import Sleeki.Inspector

  def ast(schema) do
    @generators
    |> Enum.map(& &1.ast(schema))
    |> flatten()
  end
end
