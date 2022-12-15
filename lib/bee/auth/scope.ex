defmodule Bee.Auth.Scope do
  @moduledoc false

  alias Bee.Entity.Action

  defstruct [:name, :expression]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def ast(_auth, schema, scopes, default_policy) do
    [
      scope_query_functions(schema, scopes, default_policy),
      do_scope_query_functions(),
      helper_functions()
    ]
    |> List.flatten()
  end

  def scope_query_functions(schema, scopes, default_policy) do
    (schema.entities()
     |> Enum.flat_map(& &1.actions())
     |> Enum.filter(& &1.list?)
     |> Enum.map(&scope_query_function(&1, scopes, default_policy))) ++
      [
        default_scope_query_function()
      ]
  end

  def scope_query_function(action, scopes, _default_policy) do
    action_name = action.name
    entity_name = action.entity.name
    entity_module = action.entity.module
    policies = Action.resolve_policies(action, scopes) |> Macro.escape()

    quote do
      def scope_query(unquote(entity_name), unquote(action_name), query, context) do
        context
        |> roles_from_context()
        |> do_scope_query(
          unquote(policies),
          query,
          unquote(entity_name),
          unquote(entity_module),
          context
        )
      end
    end
  end

  defp default_scope_query_function do
    quote do
      def scope_query(_entity, _action, query, _context) do
        return_nothing(query)
      end
    end
  end

  defp return_nothing_function do
    quote do
      defp return_nothing(q), do: where(q, [p], 1 == 2)
    end
  end

  defp do_scope_query_functions do
    [
      do_scope_query_no_roles(),
      do_scope_query_roles(),
      do_scope_query_allow(),
      do_scope_query_no_policy(),
      do_scope_query_deny(),
      do_scope_query_any_policy(),
      do_scope_query_all_policies(),
      do_scope_query_policy()
    ]
  end

  defp do_scope_query_no_roles do
    quote do
      defp do_scope_query(roles, _policies, q, _entity_name, _entity, _context)
           when is_nil(roles) or roles == [],
           do: return_nothing(q)
    end
  end

  defp do_scope_query_roles do
    quote do
      defp do_scope_query(roles, policies, q, entity_name, entity, context) do
        roles
        |> policy(policies)
        |> do_scope_query(q, entity_name, entity, context)
      end
    end
  end

  defp do_scope_query_no_policy do
    quote do
      defp do_scope_query(nil, q, _entity_name, _entity, _context) do
        return_nothing(q)
      end
    end
  end

  defp do_scope_query_deny do
    quote do
      defp do_scope_query(:deny, q, _entity_name, _entity, _context) do
        return_nothing(q)
      end
    end
  end

  defp do_scope_query_allow do
    quote do
      defp do_scope_query(:allow, q, _entity_name, _entity, _context) do
        q
      end
    end
  end

  defp do_scope_query_any_policy do
    quote do
      defp do_scope_query(%{any: policies}, q, entity_name, entity, context) do
        do_scope_using_policies(policies, q, entity_name, entity, context, :union)
      end
    end
  end

  defp do_scope_query_all_policies do
    quote do
      defp do_scope_query(%{all: policies}, q, entity_name, entity, context) do
        do_scope_using_policies(policies, q, entity_name, entity, context, :intersect)
      end
    end
  end

  defp do_scope_query_policy do
    quote do
      defp do_scope_query(
             %{prop: prop, value: value_spec, op: op},
             q,
             entity_name,
             entity,
             context
           ) do
        value = context |> @schema.evaluate(value_spec) |> maybe_ids()

        IO.inspect(
          prop: prop,
          value_spec: value_spec,
          op: op,
          q: q,
          entity_name: entity_name,
          entity: entity,
          context: context,
          value: value
        )

        @schema.filter(entity, prop, op, value, q, entity_name)
      end
    end
  end

  defp helper_functions do
    [
      return_nothing_function(),
      do_scope_query_using_policies_function(),
      maybe_ids_functions(),
      combine_queries_functions()
    ]
  end

  defp do_scope_query_using_policies_function do
    quote do
      defp do_scope_using_policies(policies, q, entity_name, entity, context, op) do
        with nil <-
               Enum.reduce(policies, nil, fn policy, prev ->
                 q = do_scope_query(policy, q, entity_name, entity, context)
                 combine_queries(q, prev, op)
               end),
             do: return_nothing(q)
      end
    end
  end

  defp maybe_ids_functions do
    [
      quote do
        defp maybe_ids(%{id: id}), do: id
      end,
      quote do
        defp maybe_ids(items) when is_list(items), do: Enum.map(items, &maybe_ids/1)
      end,
      quote do
        defp maybe_ids(other), do: other
      end
    ]
  end

  defp combine_queries_functions do
    [
      quote do
        defp combine_queries(q, q, _), do: q
      end,
      quote do
        defp combine_queries(q, nil, _), do: q
      end,
      quote do
        defp combine_queries(nil, prev, _), do: prev
      end,
      quote do
        defp combine_queries(q, prev, :union), do: Ecto.Query.union(q, ^prev)
      end,
      quote do
        defp combine_queries(q, prev, :intersect), do: Ecto.Query.intersect(q, ^prev)
      end
    ]
  end
end
