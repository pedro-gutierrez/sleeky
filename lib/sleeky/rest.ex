defmodule Sleeky.Rest do
  @generators [
    Sleeky.Rest.OpenApi,
    Sleeky.Rest.RouterHelper,
    Sleeky.Rest.Handlers,
    Sleeky.Rest.Router,
    Sleeky.Rest.Redoc
  ]

  import Sleeky.Inspector

  defmacro __using__(_) do
    quote do
      import Sleeky.Rest.Dsl, only: :macros
      @before_compile Sleeky.Rest
    end
  end

  defmacro __before_compile__(_env) do
    rest = __CALLER__.module
    schema = Module.get_attribute(rest, :schema)

    @generators
    |> Enum.map(& &1.ast(rest, schema))
    |> flatten()
  end
end
