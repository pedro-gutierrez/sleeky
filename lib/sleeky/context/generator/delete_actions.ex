defmodule Sleeky.Context.Generator.DeleteActions do
  @moduledoc false

  @behaviour Diesel.Generator

  import Sleeky.Naming
  import Sleeky.Context.Ast

  alias Sleeky.Entity.Action

  @impl true
  def generate(context, _) do
    for entity <- context.entities, %Action{name: :delete} = action <- entity.actions() do
      entity_name = entity.name()
      action_fun_name = String.to_atom("delete_#{entity_name}")
      context = var(:context)
      entity_var = var(entity_name)

      pre_reqs = [
        context_with_entity(entity),
        allowed?(entity, action)
      ]

      quote do
        def unquote(action_fun_name)(unquote(entity_var), unquote(context) \\ %{})

        def unquote(action_fun_name)(
              unquote(entity_var),
              unquote(context)
            ) do
          with unquote_splicing(flattened(pre_reqs)) do
            unquote(entity).delete(unquote(entity_var))
          end
        end
      end
    end
  end
end
