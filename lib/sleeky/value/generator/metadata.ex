defmodule Sleeky.Value.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl Diesel.Generator
  def generate(value, _opts) do
    quote do
      def fields, do: unquote(Macro.escape(value.fields))
    end
  end
end
