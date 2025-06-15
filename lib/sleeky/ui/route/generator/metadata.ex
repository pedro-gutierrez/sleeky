defmodule Sleeky.Ui.Route.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(route, _opts) do
    quote do
      def path, do: unquote(route.path)
      def method, do: unquote(route.method)
    end
  end
end
