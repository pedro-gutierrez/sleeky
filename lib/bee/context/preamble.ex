defmodule Bee.Context.Preamble do
  @moduledoc false

  def ast(entities, enums) do
    [
      entities_function(entities),
      enums_function(enums)
    ]
  end

  def entities_function(entities) do
    quote do
      def entities, do: unquote(entities)
    end
  end

  def enums_function(enums) do
    quote do
      def enums, do: unquote(enums)
    end
  end
end
