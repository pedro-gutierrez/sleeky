defmodule Sleeky.Html.Generator.Render do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Html

  @impl true
  def generate(html, _opts) do
    slots = %{}

    template =
      html
      |> Html.Resolve.resolve(slots)
      |> Html.Render.render()

    quote do
      @template Solid.parse!(unquote(template))

      def render(args \\ %{}) do
        @template |> Solid.render!(args) |> to_string()
      end
    end
  end
end
