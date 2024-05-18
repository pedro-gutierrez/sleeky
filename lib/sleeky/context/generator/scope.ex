defmodule Sleeky.Context.Generator.Scope do
  @moduledoc false
  @behaviour Diesel.Generator

  alias Sleeky.Context.Policies
  alias Sleeky.Context.Scopes

  @impl true
  def generate(_caller, context) do
    scope_funs(context) ++ [default_scope_fun()]
  end

  defp scope_funs(context) do
    scopes = Scopes.all(context)

    for model <- context.models, %{kind: :list} = action <- model.actions() do
      model_name = model.name()
      policies = Policies.resolve!(model_name, action, scopes)

      quote do
        def scope(%Ecto.Query{} = query, unquote(model_name), unquote(action.name), params) do
          roles = roles(params)
          policy = Policies.reduce(unquote(Macro.escape(policies)), roles)

          Sleeky.Authorization.Query.scope(
            unquote(model),
            query,
            policy.scope,
            params
          )
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
