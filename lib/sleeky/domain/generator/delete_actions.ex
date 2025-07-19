defmodule Sleeky.Domain.Generator.DeleteActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming
  import Sleeky.Domain.Ast

  alias Sleeky.Model.Action

  @impl true
  def generate(domain, _) do
    for model <- domain.models, %Action{name: :delete} = action <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("delete_#{model_name}")
      context = var(:context)
      model_var = var(model_name)

      pre_reqs = [
        context_with_model(model),
        allowed?(model, action)
      ]

      quote do
        def unquote(action_fun_name)(unquote(model_var), unquote(context) \\ %{})

        def unquote(action_fun_name)(
              unquote(model_var),
              unquote(context)
            ) do
          with unquote_splicing(flattened(pre_reqs)) do
            unquote(model).delete(unquote(model_var))
          end
        end
      end
    end
  end
end
