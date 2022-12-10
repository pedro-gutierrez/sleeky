defmodule Bee.Auth do
  @moduledoc false
  import Bee.Inspector

  @generators [
    Bee.Auth.Roles,
    Bee.Auth.Scope,
    Bee.Auth.Allow
  ]

  defmacro __using__(opts) do
    auth = __CALLER__.module
    schema = opts |> Keyword.fetch!(:schema) |> module()
    Module.put_attribute(auth, :schema, schema)

    quote do
      import Bee.Auth.Dsl, only: :macros
      @before_compile unquote(Bee.Auth)
    end
  end

  defmacro __before_compile__(_env) do
    auth = __CALLER__.module
    schema = Module.get_attribute(auth, :schema)

    @generators
    |> Enum.map(& &1.ast(auth, schema))
    |> flatten()
  end
end
