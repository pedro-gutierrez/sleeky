defmodule Sleeki.UI.View do
  @moduledoc false

  import Sleeki.Inspector

  defstruct [:route, :module, :render]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def named(name, parent) do
    parent |> context() |> module(name)
  end

  def ast(definition, view) do
    quote do
      @definition unquote(Macro.escape(definition))

      def definition, do: @definition

      def render(args \\ %{}) do
        args
        |> resolve()
        |> Sleeki.UI.Html.render()
      rescue
        e ->
          raise """
          Error rendering view #{inspect(unquote(view))}:
          #{Exception.format(:error, e, __STACKTRACE__)}"
          """
      end

      def resolve(args \\ %{}) do
        with {node, attrs, children} when is_list(children) <-
               Sleeki.UI.View.Resolve.resolve(@definition, args) do
          {node, attrs, List.flatten(children)}
        end
      rescue
        e ->
          raise """
          Error resolving view #{inspect(unquote(view))}:
          #{Exception.format(:error, e, __STACKTRACE__)}"
          """
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Sleeki.UI.View.Dsl, only: :macros
      @before_compile Sleeki.UI.View
    end
  end

  defmacro __before_compile__(_env) do
    view = __CALLER__.module

    view
    |> Module.get_attribute(:definition)
    |> ast(view)
  end
end
