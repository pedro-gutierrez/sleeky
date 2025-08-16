defmodule Sleeky.Feature.Generator.UpdateFunctions do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(feature, _) do
    for model <- feature.models do
      model_name = model.name()
      action_fun_name = String.to_atom("update_#{model_name}")
      do_action_fun_name = String.to_atom("do_update_#{model_name}")

      attr_names =
        for attr when attr.mutable? and not attr.computed? <- model.attributes(),
            do: attr.name

      parent_fields =
        for rel when rel.mutable? and not rel.computed? <- model.parents(),
            into: %{},
            do: {rel.name, rel.column_name}

      do_update_fun =
        quote do
          defp unquote(do_action_fun_name)(model, attrs, context) do
            fields =
              attrs
              |> Map.take(unquote(attr_names))
              |> collect_ids(attrs, unquote(Macro.escape(parent_fields)))

            unquote(model).edit(model, fields)
          end
        end

      fun_with_map_args =
        quote do
          def unquote(action_fun_name)(model, attrs, context \\ %{})

          def unquote(action_fun_name)(model, attrs, context) when is_map(attrs) do
            context = attrs |> Map.merge(context) |> Map.put(unquote(model_name), model)
            repo = repo()
            unquote(do_action_fun_name)(model, attrs, context)
          end
        end

      fun_with_kw_args =
        quote do
          def unquote(action_fun_name)(model, attrs, context) when is_list(attrs) do
            attrs = Map.new(attrs)

            unquote(action_fun_name)(model, attrs, context)
          end
        end

      [do_update_fun, fun_with_map_args, fun_with_kw_args]
    end
  end
end
