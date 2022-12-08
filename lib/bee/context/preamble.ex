defmodule Bee.Context.Preamble do
  @moduledoc false

  def ast(entities, enums, _opts) do
    [
      imports(),
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

  def imports do
    quote do
      import Ecto.Query
    end
  end
end
