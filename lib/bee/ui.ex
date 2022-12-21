defmodule Bee.UI do
  @moduledoc false

  @generators [
    Bee.UI.Preamble,
    Bee.UI.Router
  ]

  import Bee.Inspector

  defmacro __using__(_) do
    ui = __CALLER__.module

    Module.register_attribute(ui, :views, accumulate: true, persist: true)

    quote do
      import Bee.UI.Dsl, only: :macros
      @before_compile Bee.UI
    end
  end

  defmacro __before_compile__(_env) do
    ui = __CALLER__.module
    views = Module.get_attribute(ui, :views)

    @generators
    |> Enum.map(& &1.ast(ui, views))
    |> flatten()
  end
end
