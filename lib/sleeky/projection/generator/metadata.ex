defmodule Sleeky.Projection.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(projection, _opts) do
    quote do
      def fields, do: unquote(Macro.escape(projection.fields))
    end
  end
end
