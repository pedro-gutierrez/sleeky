defmodule Sleeky.Domain.Generator.Scope do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Domain.Policies
  alias Sleeky.Domain.Scopes

  @impl true
  def generate(context, _) do
    scope_funs(context) ++ [default_scope_fun()]
  end

  defp scope_funs(context) do
    scopes = Scopes.all(context)

    for model <- context.models, %{kind: :list} = action <- model.actions() do
      model_name = model.name()
      policies = Policies.resolve!(model_name, action, scopes)

      quote location: :keep do
        def scope(
              %Ecto.Query{} = query,
              unquote(model_name) = model,
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

              when scoping action #{action} on model #{model}
              """
            else
              Sleeky.Scopes.Query.scope(
                unquote(model),
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
