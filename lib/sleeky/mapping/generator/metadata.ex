defmodule Sleeky.Mapping.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(mapping, _opts) do
    quote do
      def from, do: unquote(mapping.from)
      def to, do: unquote(mapping.to)
      def fields, do: unquote(Macro.escape(mapping.fields))
      def feature, do: unquote(mapping.feature)
      def name, do: unquote(mapping.name)
    end
  end
end
