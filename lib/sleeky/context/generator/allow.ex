defmodule Sleeky.Context.Generator.Allow do
  @moduledoc """
  Generates authorization code for a context
  """
  @behaviour Diesel.Generator

  alias Sleeky.Context.Policies
  alias Sleeky.Context.Scopes

  @impl true
  def generate(context, _) do
    scopes = Scopes.all(context)

    for model <- context.models, action <- model.actions() do
      model = model.name()
      policies = Policies.resolve!(model, action, scopes)

      quote do
        def allow(unquote(model), unquote(action.name), params) do
          roles = roles(params) || []

          if roles == [] do
            :ok
          else
            policy = Policies.reduce(unquote(Macro.escape(policies)), roles)

            if Sleeky.Authorization.Action.allow?(
                 unquote(model),
                 unquote(action.name),
                 policy,
                 params
               ),
               do: :ok,
               else: {:error, :forbidden}
          end
        end
      end
    end
  end
end
