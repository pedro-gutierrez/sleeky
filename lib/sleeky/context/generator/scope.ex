defmodule Sleeky.Context.Generator.Scope do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Context.Policies
  alias Sleeky.Context.Scopes

  @impl true
  def generate(context, _) do
    scope_funs(context) ++ [default_scope_fun()]
  end

  defp scope_funs(context) do
    scopes = Scopes.all(context)

    for entity <- context.entities, %{kind: :list} = action <- entity.actions() do
      entity_name = entity.name()
      policies = Policies.resolve!(entity_name, action, scopes)

      quote location: :keep do
        def scope(
              %Ecto.Query{} = query,
              unquote(entity_name) = entity,
              unquote(action.name) = action,
              params
            ) do
          roles = roles(params) || []

          if roles == [] do
            query
          else
            policies = unquote(Macro.escape(policies))
            policy = Policies.reduce(policies, roles)

            if policy == nil do
              raise """
              No policy found for roles

                #{inspect(roles)}

              when scoping action #{action} on entity #{entity}
              """
            else
              Sleeky.Scopes.Query.scope(
                unquote(entity),
                query,
                policy.scope,
                params
              )
            end
          end
        end
      end
    end
  end

  defp default_scope_fun do
    quote do
      def scope(_, _, _, _), do: {:error, :not_supported}
    end
  end
end
