defmodule Sleeky.Ui do
  @moduledoc false

  @generators [
    Sleeky.Ui.Router
  ]

  import Sleeky.Inspector

  defmacro __using__(_) do
    ui = __CALLER__.module

    Module.register_attribute(ui, :views, accumulate: true, persist: true)
    Module.register_attribute(ui, :schema, accumulate: false, persist: true)

    schema = ui |> context() |> module(Schema)
    Module.put_attribute(ui, :schema, schema)

    quote do
      import Sleeky.Ui.Dsl, only: :macros
      @before_compile Sleeky.Ui
    end
  end

  defmacro __before_compile__(_env) do
    ui = __CALLER__.module
    views = Module.get_attribute(ui, :views)
    schema = Module.get_attribute(ui, :schema)

    @generators
    |> Enum.map(& &1.ast(ui, views, schema))
    |> flatten()
  end
end
