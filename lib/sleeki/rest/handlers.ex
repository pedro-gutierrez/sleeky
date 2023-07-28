defmodule Sleeki.Rest.Handlers do
  @moduledoc false

  import Sleeki.Inspector

  def generators do
    [
      Sleeki.Rest.Handlers.Default,
      Sleeki.Rest.Handlers.Aggregates,
      Sleeki.Rest.Handlers.Children
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
