defmodule Sleeky.Model.Generator.Query do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(model, _) do
    item = Macro.var(:item, nil)

    quote do
      def query, do: from(unquote(item) in unquote(model.module), as: unquote(model.name))
    end
  end
end
