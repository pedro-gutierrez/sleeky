defmodule Sleeky.Context.Generator.ReadActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Ast
  import Sleeky.Context.Ast

  alias Sleeky.Model.Action

  @impl true
  def generate(_caller, context) do
    for model <- context.models, %Action{name: :read} = action <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("read_#{model_name}")
      context = var(:context)
      model_var = var(model_name)
      id_var = var(:id)

      steps = [
        fetch_model(model),
        context_with_model(model),
        allowed?(model, action)
      ]

      quote do
        def unquote(action_fun_name)(unquote(id_var), unquote(context)) do
          with unquote_splicing(flattened(steps)) do
            {:ok, unquote(model_var)}
          end
        end
      end
    end
  end
end
