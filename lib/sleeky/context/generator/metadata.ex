defmodule Sleeky.Context.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_context, context) do
    quote do
      def name, do: unquote(context.name)
      def models, do: unquote(context.models)
    end
  end
end
