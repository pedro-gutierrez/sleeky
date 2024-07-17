defmodule Sleeky.Context.Generator.ReadActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming

  alias Sleeky.Model.Action

  @impl true
  def generate(context, _) do
    for model <- context.models, %Action{name: :read} = action <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("read_#{model_name}")

      quote do
        def unquote(action_fun_name)(id, context) do
          opts = context |> Map.take([:preload]) |> Keyword.new()

          with {:ok, model} <- unquote(model).fetch(id, opts),
               context <- Map.put(context, unquote(model_name), model),
               :ok <- allow(unquote(model_name), unquote(action.name), context) do
            {:ok, model}
          end
        end
      end
    end
  end
end
