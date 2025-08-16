defmodule Sleeky.Event.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(event, _opts) do
    quote do
      def fields, do: unquote(Macro.escape(event.fields))
      def version, do: unquote(event.version)
      def feature, do: unquote(event.feature)
      def name, do: unquote(event.name)
    end
  end
end
