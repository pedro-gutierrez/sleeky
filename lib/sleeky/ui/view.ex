defmodule Sleeky.UI.View do
  @moduledoc false

  import Sleeky.Inspector

  defstruct [:route, :module, :render]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def named(name, parent) do
    parent |> context() |> module(name)
  end

  def ast(definition, _view) do
    quote do
      use Sleeky.UI.View

      def definition, do: unquote(Macro.escape(definition))
    end
  end

  defmacro __using__(_opts) do
    quote do
      use Sleeky.Ui.Html
      use Sleeky.Ui.Composition
      import Sleeky.UI.View, only: :macros

      def to_html(args \\ %{}) do
        args
        |> resolve()
        |> Sleeky.Ui.Html.to_html()
      rescue
        e ->
          trace = Exception.format(:error, e, __STACKTRACE__)
          raise_error("Error converting to html", trace)
      end

      def resolve(args \\ %{}) do
        with {node, attrs, children} when is_list(children) <-
               definition() |> Sleeky.UI.View.Resolve.resolve(args) do
          {node, attrs, List.flatten(children)}
        end
      rescue
        e ->
          trace = Exception.format(:error, e, __STACKTRACE__)
          raise_error("Error resolving", trace)
      end

      defp raise_error(reason, trace) do
        raise """
        #{reason} #{inspect(__MODULE__)}: #{trace}
        """
      end
    end
  end

  defmacro render(do: child) do
    quote do
      def definition, do: unquote(child)
    end
  end
end
