defmodule Sleeky.Ui.Namespace.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(ns, _opts) do
    quote do
      def path, do: unquote(ns.path)
    end
  end
end
