defmodule Bee.Context.Info do
  @moduledoc false

  def ast(entities, enums, _opts) do
    [
      quote do
        def entities, do: unquote(entities)
        def enums, do: unquote(enums)
      end
    ]
  end
end
