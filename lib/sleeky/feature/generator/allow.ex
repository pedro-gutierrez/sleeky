defmodule Sleeky.Feature.Generator.Allow do
  @moduledoc """
  Generates authorization code for a feature
  """
  @behaviour Diesel.Generator

  alias Sleeky.Feature.Policies
  alias Sleeky.Feature.Scopes

  @impl true
  def generate(feature, _) do
    scopes = Scopes.all(feature)

    for model <- feature.models, action <- model.actions() do
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
