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

    for entity <- context.entities, action <- entity.actions() do
      entity = entity.name()
      policies = Policies.resolve!(entity, action, scopes)

      quote do
        def allow(unquote(entity), unquote(action.name), params) do
          roles = roles(params) || []

          if roles == [] do
            :ok
          else
            policy = Policies.reduce(unquote(Macro.escape(policies)), roles)

            if Sleeky.Scopes.Action.allow?(
                 unquote(entity),
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
