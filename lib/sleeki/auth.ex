defmodule Sleeki.Auth do
  @moduledoc false
  import Sleeki.Inspector

  @generators [
    Sleeki.Auth.Role,
    Sleeki.Auth.Policy,
    Sleeki.Auth.Scope,
    Sleeki.Auth.Allow
  ]

  def schema!(auth) do
    with nil <- Module.get_attribute(auth, :schema) do
      raise "No schema defined in auth module #{inspect(auth)}"
    end
  end

  def scopes!(auth) do
    Module.get_attribute(auth, :scopes)
  end

  defmacro __using__(_opts) do
    auth = __CALLER__.module

    Module.register_attribute(auth, :scopes, persist: false, accumulate: true)

    schema = auth |> context() |> module(Schema)
    Module.put_attribute(auth, :schema, schema)

    quote do
      import Sleeki.Auth.Dsl, only: :macros
      import Ecto.Query
      @schema unquote(schema)
      @before_compile unquote(Sleeki.Auth)
    end
  end

  defmacro __before_compile__(_env) do
    auth = __CALLER__.module
    scopes = Sleeki.Auth.Scope.Resolver.scopes(auth)
    schema = Sleeki.Auth.schema!(auth)
    default_policy = :deny

    @generators
    |> Enum.map(& &1.ast(auth, schema, scopes, default_policy))
    |> flatten()
  end
end
