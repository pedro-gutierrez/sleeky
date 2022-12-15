defmodule Bee.Auth.Policy do
  @moduledoc false

  def ast(_auth, _schema, _scopes, _default_policy) do
    [
      policy_function(),
      no_role_policy_allow_function(),
      roles_policy_allow_function(),
      allow_policy_allow_function(),
      deny_policy_allow_function(),
      any_policy_allow_function(),
      all_policies_allow_function(),
      single_policy_allow_function()
    ]
  end

  defp policy_function do
    quote do
      defp policy(roles, policies) do
        roles
        |> Enum.map(&Map.get(policies, &1))
        |> Enum.reject(&is_nil/1)
        |> case do
          [] -> nil
          [policy] -> policy
          policies -> %{any: policies}
        end
      end
    end
  end

  defp no_role_policy_allow_function do
    quote do
      defp policy_allow?(roles, _policies, default_policy, _context)
           when is_nil(roles) or roles == [] do
        default_policy == :allow
      end
    end
  end

  defp roles_policy_allow_function do
    quote do
      defp policy_allow?(roles, policies, default_policy, context) do
        case policy(roles, policies) do
          nil -> default_policy == :allow
          policy -> policy_allow?(policy, context)
        end
      end
    end
  end

  defp allow_policy_allow_function do
    quote do
      defp policy_allow?(:allow, _context), do: true
    end
  end

  defp deny_policy_allow_function do
    quote do
      defp policy_allow?(:deny, _context), do: false
    end
  end

  defp any_policy_allow_function() do
    quote do
      defp policy_allow?(%{any: policies}, context) do
        Enum.reduce_while(policies, false, fn policy, _ ->
          case policy_allow?(policy, context) do
            true -> {:halt, true}
            false -> {:cont, false}
          end
        end)
      end
    end
  end

  defp all_policies_allow_function do
    quote do
      defp policy_allow?(%{all: policies}, context) do
        Enum.reduce_while(policies, false, fn policy, _ ->
          case policy_allow?(policy, context) do
            true -> {:cont, true}
            false -> {:halt, false}
          end
        end)
      end
    end
  end

  defp single_policy_allow_function do
    quote do
      defp policy_allow?(%{prop: prop_spec, value: value_spec, op: op}, context) do
        prop = @schema.evaluate(context, prop_spec)
        value = @schema.evaluate(context, value_spec)
        result = @schema.compare(prop, value, op)

        IO.inspect(
          context: context,
          prop_spec: prop_spec,
          value_spec: value_spec,
          prop: prop,
          value: value,
          result: result
        )

        result
      end
    end
  end

  #    defp do_policy_allow?(%{prop: prop_spec, value: value_spec, op: op}, args, context, paths) do

  #      prop =
  #        paths
  #        |> Enum.reduce_while(nil, fn path, _ ->
  #          case context |> Map.get(path) |> evaluate(prop_spec) do
  #            nil -> {:cont, nil}
  #            value -> {:halt, value}
  #          end
  #        end)
  #        |> case do
  #          nil -> evaluate(context, prop_spec)
  #          prop -> prop
  #        end

  #    end

  #    defp do_policy_allow?({policy, scopes}, args, context, paths) do
  #      with true <- do_policy_allow?(scopes, args, context, paths) do
  #        policy == :allow
  #      end
  #    end
end
