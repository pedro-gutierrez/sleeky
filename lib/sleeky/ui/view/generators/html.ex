defmodule Sleeky.Ui.View.Generators.Html do
  @moduledoc "Generates code that allows a view to render as plain html"
  @behaviour Diesel.Generator

  @impl true
  def generate(_view, _definition) do
    quote do
      @doc false
      def to_html(args \\ %{}) do
        _ = Sleeky.tags()

        args
        |> compile()
        |> Sleeky.Ui.Html.render()
      rescue
        e ->
          trace = Exception.format(:error, e, __STACKTRACE__)

          raise """
          Error converting view #{inspect(__MODULE__)} into html: #{trace}
          """
      end
    end
  end
end
