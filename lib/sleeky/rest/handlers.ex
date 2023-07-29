defmodule Sleeky.Rest.Handlers do
  @moduledoc false

  import Sleeky.Inspector

  def generators do
    [
      Sleeky.Rest.Handlers.Default,
      Sleeky.Rest.Handlers.Aggregates,
      Sleeky.Rest.Handlers.Children
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
