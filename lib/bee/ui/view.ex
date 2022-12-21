defmodule Bee.UI.View do
  @moduledoc false

  import Bee.Inspector

  @generators [
    Bee.UI.View.Render
  ]

  defstruct [:route, :module, :render]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def named(name, parent) do
    parent |> context() |> module(name)
  end

  defmacro __using__(_opts) do
    quote do
      import Bee.UI.View.Dsl, only: :macros
      @before_compile Bee.UI.View
    end
  end

  defmacro __before_compile__(_env) do
    page = __CALLER__.module

    @generators
    |> Enum.map(& &1.ast(page))
    |> flatten()
  end
end
