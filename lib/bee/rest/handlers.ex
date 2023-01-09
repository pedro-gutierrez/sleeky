defmodule Bee.Rest.Handlers do
  @moduledoc false

  import Bee.Inspector

  def generators do
    [
      Bee.Rest.Handlers.Default,
      Bee.Rest.Handlers.Aggregates,
      Bee.Rest.Handlers.Children
    ]
  end

  def ast(rest, schema) do
    schema.entities()
    |> Enum.map(&handlers(rest, &1))
    |> flatten()
  end

  defp handlers(rest, entity) do
    for generator <- generators() do
      generator.handlers(entity, rest)
    end
  end
end
