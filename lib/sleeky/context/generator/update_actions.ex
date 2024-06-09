defmodule Sleeky.Context.Generator.UpdateActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming
  import Sleeky.Context.Ast

  alias Sleeky.Model.Action

  @impl true
  def generate(_caller, context) do
    for model <- context.models, %Action{name: :update} = action <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("update_#{model_name}")
      attrs = var(:attrs)
      context = var(:context)
      model_var = var(model_name)
      parent_vars = function_parent_args(model)

      pre_reqs = [
        context_with_parents(model),
        context_with_model(model),
        attrs_with_required_parents(model),
        attrs_with_optional_parents(model),
        attrs_with_computed_attributes(model),
        context_with_args(),
        allowed?(model, action)
      ]

      quote do
        def unquote(action_fun_name)(
              unquote_splicing(parent_vars),
              unquote(model_var),
              unquote(attrs),
              unquote(context)
            ) do
          with unquote_splicing(flattened(pre_reqs)) do
            unquote(model).edit(unquote(model_var), unquote(attrs))
          end
        end
      end
    end
  end
end
