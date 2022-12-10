defmodule Bee.Auth.Roles do
  @moduledoc false

  import Bee.Inspector

  def ast(auth, schema) do
    roles_expr = Module.get_attribute(auth, :roles_expression)

    unless roles_expr do
      raise "No roles expression defined in your auth module"
    end

    context = var(:context)

    quote do
      def roles(unquote(context)) do
        unquote(schema).evaluate(unquote(context), unquote(roles_expr))
      end
    end
    |> print()
  end
end
