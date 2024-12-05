defmodule Sleeky.Ui.View.Generator.Render do
  @moduledoc false
  @behaviour Diesel.Generator

  # alias Sleeky.Ui.View

  @impl true
  def generate(html, _opts) do
    html = Sleeky.Ui.View.Expand.expand(html)

    quote do
      @expanded_source unquote(Macro.escape(html))

      def render(args \\ %{}) do
        @expanded_source
        |> Sleeky.Ui.View.Resolve.resolve(args)
        |> Sleeky.Ui.View.Render.render()
      end
    end
  end
end
