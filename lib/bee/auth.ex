defmodule Bee.Auth do
  @moduledoc false
  import Bee.Inspector

  @generators [
    Bee.Auth.Role,
    Bee.Auth.Policy,
    Bee.Auth.Scope,
    Bee.Auth.Allow
  ]

  def schema!(auth) do
    with nil <- Module.get_attribute(auth, :schema) do
      raise "No schema defined in auth module #{inspect(auth)}"
    end
  end

  defmacro __using__(_opts) do
    auth = __CALLER__.module

    schema = auth |> context() |> module(Schema)
    Module.put_attribute(auth, :schema, schema)

    quote do
      import Bee.Auth.Dsl, only: :macros
      import Ecto.Query
      @schema unquote(schema)
      @before_compile unquote(Bee.Auth)
    end
  end

  defmacro __before_compile__(_env) do
    auth = __CALLER__.module

    @generators
    |> Enum.map(& &1.ast(auth))
    |> flatten()
    |> print()
  end
end
