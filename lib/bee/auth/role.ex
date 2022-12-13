defmodule Bee.Auth.Role do
  @moduledoc false

  import Bee.Inspector

  def ast(auth) do
    [
      roles_from_context_function(auth),
      no_role_allow_function(),
      role_allow_function()
    ]
  end

  defp roles_from_context_function(auth) do
    roles_expr = Module.get_attribute(auth, :roles_expression)

    unless roles_expr do
      raise "No roles expression defined in your auth module"
    end

    context = var(:context)

    quote do
      def roles_from_context(unquote(context)) do
        @schema.evaluate(unquote(context), unquote(roles_expr))
      end
    end
  end

  defp no_role_allow_function do
    quote do
      defp role_allow?(roles, _policies, _default_policy, _context)
           when roles == nil or roles == [] do
        false
      end
    end
  end

  defp role_allow_function do
    quote do
      defp role_allow?(roles, policies, _default_policy, _) do
        roles
        |> Enum.map(&Keyword.get(policies, &1))
        |> Enum.reject(&is_nil/1)
        |> case do
          [] ->
            false

          _ ->
            # we would need to check if any of these policies are explicitly denying
            # the action. For now, we assume the presence means it is okay
            # and we will let the scope function to filter out results
            true
        end
      end
    end
  end
end
