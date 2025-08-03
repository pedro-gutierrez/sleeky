defmodule Sleeky.Entity.Generator.Query do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(entity, _) do
    item = Macro.var(:item, nil)

    quote do
      def query, do: from(unquote(item) in unquote(entity.module), as: unquote(entity.name))
    end
  end
end
