defmodule Bee.Auth.Allow do
  @moduledoc false

  alias Bee.Entity.Action

  def ast(_auth, schema, scopes, default_policy) do
    ok_or_unauthorized_function() ++ allow_actions(schema, scopes, default_policy)
  end

  def ok_or_unauthorized_function do
    [
      quote do
        defp ok_or_unauthorized(false), do: {:error, :unauthorized}
      end,
      quote do
        defp ok_or_unauthorized(true), do: :ok
      end
    ]
  end

  def allow_actions(schema, scopes, default_policy) do
    schema.entities()
    |> Enum.flat_map(& &1.actions())
    |> Enum.map(&allow_action_function(&1, scopes, default_policy))
  end

  def allow_action_function(action, scopes, default_policy) do
    if action.list? do
      allow_action_function_using_role(action, scopes, default_policy)
    else
      allow_action_function_using_policy(action, scopes, default_policy)
    end
  end

  def allow_action_function_using_role(action, scopes, default_policy) do
    action_name = action.name
    entity_name = action.entity.name
    policies = Action.resolve_policies(action, scopes) |> Macro.escape()

    quote do
      def allow_action(unquote(entity_name), unquote(action_name), context) do
        context
        |> roles_from_context()
        |> policy_allow?(unquote(policies), unquote(default_policy), context)
        |> ok_or_unauthorized()
      end
    end
  end

  def allow_action_function_using_policy(action, scopes, default_policy) do
    action_name = action.name
    entity_name = action.entity.name
    policies = Action.resolve_policies(action, scopes) |> Macro.escape()

    quote do
      def allow_action(unquote(entity_name), unquote(action_name), context) do
        context
        |> roles_from_context()
        |> role_allow?(unquote(policies), unquote(default_policy), context)
        |> ok_or_unauthorized()
      end
    end
  end
end
