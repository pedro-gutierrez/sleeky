defmodule Sleeky.Domain.Generator.Allow do
  @moduledoc """
  Generates authorization code for a domain
  """
  @behaviour Diesel.Generator

  alias Sleeky.Domain.Policies
  alias Sleeky.Domain.Scopes

  @impl true
  def generate(domain, _) do
    scopes = Scopes.all(domain)

    for model <- domain.models, action <- model.actions() do
      model = model.name()
      policies = Policies.resolve!(model, action, scopes)

      quote do
        def allow(unquote(model), unquote(action.name), params) do
          roles = roles(params) || []

          if roles == [] do
            :ok
          else
            policy = Policies.reduce(unquote(Macro.escape(policies)), roles)

            if Sleeky.Scopes.Action.allow?(
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
