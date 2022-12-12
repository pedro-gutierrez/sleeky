defmodule Bee.Schema.Preamble do
  @moduledoc false

  def ast(schema) do
    [
      entities_function(schema),
      enums_function(schema)
    ]
  end

  defp entities_function(schema) do
    entities = Bee.Schema.entities!(schema)

    quote do
      def entities, do: unquote(entities)
    end
  end

  defp enums_function(schema) do
    enums = Bee.Schema.enums!(schema)

    quote do
      def enums, do: unquote(enums)
    end
  end
end
