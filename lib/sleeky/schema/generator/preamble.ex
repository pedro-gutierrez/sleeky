defmodule Sleeky.Schema.Generator.Preamble do
  @moduledoc false
  @behaviour Diesel.Generator
  import Sleeky.Schema.Definition

  @impl true
  def generate(_schema, definition) do
    entities = entities(definition)
    enums = enums(definition)

    quote do
      def entities, do: unquote(entities)
      def enums, do: unquote(enums)
    end
  end
end
