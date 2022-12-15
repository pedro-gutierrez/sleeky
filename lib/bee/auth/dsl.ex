defmodule Bee.Auth.Dsl do
  @moduledoc false

  alias Bee.Auth.Scope

  defmacro roles(expr) do
    auth = __CALLER__.module
    Module.put_attribute(auth, :roles_expression, expr)
  end

  defmacro scope(name, block) do
    auth = __CALLER__.module
    scope = Scope.Parser.parse(name, block)

    Module.put_attribute(auth, :scopes, scope)
  end
end
