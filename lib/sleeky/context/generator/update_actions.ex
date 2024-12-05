defmodule Sleeky.Context.Generator.UpdateActions do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(context, _) do
    for model <- context.models, action when action.name == :update <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("update_#{model_name}")

      attr_names =
        for attr when attr.mutable? and not attr.computed? <- model.attributes(),
            do: attr.name

      parent_fields =
        for rel when rel.mutable? and not rel.computed? <- model.parents(),
            into: %{},
            do: {rel.name, rel.column_name}

      quote do
        def unquote(action_fun_name)(model, attrs, context \\ %{})

        def unquote(action_fun_name)(model, attrs, context) when is_list(attrs) do
          attrs = Map.new(attrs)

          unquote(action_fun_name)(model, attrs, context)
        end

        def unquote(action_fun_name)(model, attrs, context) when is_map(attrs) do
          context = attrs |> Map.merge(context) |> Map.put(unquote(model_name), model)

          fields =
            attrs
            |> Map.take(unquote(attr_names))
            |> collect_ids(attrs, unquote(Macro.escape(parent_fields)))

          with :ok <- allow(unquote(model_name), unquote(action.name), context) do
            unquote(model).edit(model, fields)
          end
        end
      end
    end
  end
end
