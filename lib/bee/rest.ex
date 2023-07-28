defmodule Sleeki.Rest do
  @generators [
    Sleeki.Rest.OpenApi,
    Sleeki.Rest.RouterHelper,
    Sleeki.Rest.Handlers,
    Sleeki.Rest.Router,
    Sleeki.Rest.Redoc
  ]

  import Sleeki.Inspector

  defmacro __using__(_) do
    quote do
      import Sleeki.Rest.Dsl, only: :macros
      @before_compile Sleeki.Rest
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
