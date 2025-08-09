defmodule Sleeky.Scope.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(scope, _opts) do
    quote do
      def debug?, do: unquote(scope.debug)
      def expression, do: unquote(Macro.escape(scope.expression))
    end
  end
end
