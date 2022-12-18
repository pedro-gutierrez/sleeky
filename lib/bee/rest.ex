defmodule Bee.Rest do
  @generators [
    Bee.Rest.OpenApi,
    Bee.Rest.RouterHelper,
    Bee.Rest.Handlers,
    Bee.Rest.Router,
    Bee.Rest.Redoc
  ]

  import Bee.Inspector

  defmacro __using__(_) do
    quote do
      import Bee.Rest.Dsl, only: :macros
      @before_compile Bee.Rest
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
