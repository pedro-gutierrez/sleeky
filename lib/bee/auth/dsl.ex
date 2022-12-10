defmodule Bee.Auth.Dsl do
  @moduledoc false

  defmacro roles(expr) do
    auth = __CALLER__.module
    Module.put_attribute(auth, :roles_expression, expr)
  end
end
