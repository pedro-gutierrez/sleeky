defmodule Sleeky.Ui.View.Generator.Source do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(html, _opts) do
    quote do
      @source unquote(Macro.escape(html))

      def source, do: @source
    end
  end
end
