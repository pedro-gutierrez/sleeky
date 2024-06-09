defmodule Sleeky.Context.Generator.CreateActions do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(context, _) do
    for model <- context.models, %{name: :create} = action <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("create_#{model_name}")

      attr_names =
        for attr when not attr.computed? <- model.attributes(),
            do: attr.name

      parent_fields =
        for rel when not rel.computed? <- model.parents(),
            into: %{},
            do: {rel.name, rel.column_name}

      child_fields =
        for rel when not rel.computed? <- model.children(),
            do: rel.name

      quote do
        def unquote(action_fun_name)(attrs, context) do
          context = Map.merge(attrs, context)

          fields =
            attrs
            |> Map.take(unquote(attr_names))
            |> collect_ids(attrs, unquote(Macro.escape(parent_fields)))
            |> collect_values(attrs, unquote(child_fields))

          with :ok <- allow(unquote(model_name), unquote(action.name), context) do
            unquote(model).create(fields)
          end
        end
      end
    end
  end
end
