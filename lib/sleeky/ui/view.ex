defmodule Sleeky.Ui.View do
  @moduledoc """
  A Sleeky UI is made of Sleeky views.

  Usage:

  ```elixir
  defmodule MyApp.Ui.SomeView do
    use Sleeky.Ui.View

    render do
      html do
        head do
          title "This is some nice title"
          meta charset: "utf-8"
        end

        body do
          h1 class: "title" do
            "It works!"
          end
        end
      end
    end
  end
  ```

  Views are expressed in pure Elixir, then compiled into an internal representation made of simple
    tuples nested one within another, quite similar to what Floki does. Views can be expressed in
    terms of other views. Resolving a view traverses all these dependencies and produces a final,
    single internal representation that no longer depends on anything. Finally, once resolved, a
    view gets rendered into plain html, in order to be served by a router.

  By default, all this process happens during compile time. However, it is also possible to delay
    the resolution right to the point when the view is about to be served by the Ui router:

  ```elixir
  defmodule Sleeky.Ui.SomeView do
    use Sleeky.View, resolution: :runtime
    ...
  end
  ```

  This can be handy for example when running in development mode.
  """

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
      use Sleeky.Ui.View

      def definition, do: unquote(Macro.escape(definition))
    end
  end

  defmacro __using__(opts) do
    resolution = Keyword.get(opts, :resolution, :compilation)

    quote do
      use Sleeky.Ui.Html.Dsl
      use Sleeky.Ui.Compound.Dsl

      import Sleeky.Ui.View, only: :macros

      @doc "Determines whether the view should be resolved during compilation or runtime"
      def resolution, do: unquote(resolution)

      @doc "Resolves and renders the view into html"
      def to_html(args \\ %{}) do
        args
        |> resolve()
        |> Sleeky.Ui.Render.to_html()
      rescue
        e ->
          trace = Exception.format(:error, e, __STACKTRACE__)
          raise_error("Error converting to html", trace)
      end

      @doc "Resolves all dependencies, recursively, and returns a new internal definition"
      def resolve(args \\ %{}) do
        with {node, attrs, children} when is_list(children) <-
               definition() |> Sleeky.Ui.Resolve.resolve(args) do
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
