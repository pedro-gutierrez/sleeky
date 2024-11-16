defmodule Sleeky.Ui.View.Generator.Source do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(html, _opts) do
    quote do
      def dynamic?, do: false
      def source, do: unquote(Macro.escape(html))
    end
  end
end
