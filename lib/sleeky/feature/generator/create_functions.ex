defmodule Sleeky.Feature.Generator.CreateFunctions do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(feature, _) do
    create_funs(feature) ++
      do_create_funs(feature) ++ bulk_create_funs(feature) ++ create_children_funs(feature)
  end

  defp create_funs(feature) do
    for model <- feature.models do
      model_name = model.name()
      action_fun_name = String.to_atom("create_#{model_name}")
      do_action_fun_name = String.to_atom("do_create_#{model_name}")
      children_action_fun_name = String.to_atom("create_#{model_name}_children")

      fun_with_map_args =
        quote location: :keep do
          def unquote(action_fun_name)(attrs, context \\ %{})

          def unquote(action_fun_name)(attrs, context) when is_map(attrs) do
            repo = repo()

            repo.transaction(fn ->
              with {:ok, model} <- unquote(do_action_fun_name)(attrs, context),
                   :ok <- unquote(children_action_fun_name)(model, attrs, context) do
                model
              else
                {:error, reason} ->
                  repo.rollback(reason)
              end
            end)
          end
        end

      fun_with_kw_args =
        quote location: :keep do
          def unquote(action_fun_name)(attrs, context) when is_list(attrs) do
            attrs
            |> Map.new()
            |> unquote(action_fun_name)()
          end
        end

      [fun_with_map_args, fun_with_kw_args]
    end
  end

  defp do_create_funs(feature) do
    for model <- feature.models do
      model_name = model.name()
      action_fun_name = String.to_atom("do_create_#{model_name}")

      attr_names =
        for attr when not attr.computed? <- model.attributes(),
            do: attr.name

      parent_fields =
        for rel when not rel.computed? <- model.parents(),
            into: %{},
            do: {rel.name, rel.column_name}

      default_values =
        for attr when not is_nil(attr.default) <- model.attributes(), into: %{} do
          {attr.name, attr.default}
        end

      quote location: :keep do
        defp unquote(action_fun_name)(attrs, context) do
          attrs
          |> Map.take(unquote(attr_names))
          |> collect_ids(attrs, unquote(Macro.escape(parent_fields)))
          |> Sleeky.Feature.Helpers.set_default_values(unquote(Macro.escape(default_values)))
          |> Sleeky.Maps.string_keys()
          |> Map.put_new_lazy("id", &Ecto.UUID.generate/0)
          |> unquote(model).create()
        end
      end
    end
  end

  defp create_children_funs(feature) do
    for model <- feature.models do
      model_name = model.name()
      action_fun_name = String.to_atom("create_#{model_name}_children")

      child_fields =
        for rel when not rel.computed? <- model.children(),
            do: {rel.name, rel.inverse.name, String.to_atom("create_#{rel.target.name}")}

      quote location: :keep do
        defp unquote(action_fun_name)(model, attrs, context) do
          context = Map.put(context, unquote(model_name), model)

          unquote(Macro.escape(child_fields))
          |> Enum.reduce([], fn {child_name, inverse_name, create_fun_name}, acc ->
            case Map.get(attrs, child_name) do
              children when is_list(children) ->
                Enum.map(children, &{Map.put(&1, inverse_name, model), create_fun_name})

              _ ->
                []
            end
          end)
          |> List.flatten()
          |> Enum.map(fn {child, create_fun_name} ->
            apply(__MODULE__, create_fun_name, [child, context])
          end)
          |> Enum.reduce_while(:ok, fn
            {:ok, _}, _ -> {:cont, :ok}
            {:error, _} = error, _ -> {:halt, error}
          end)
        end
      end
    end
  end

  defp bulk_create_funs(feature) do
    for model <- feature.models do
      single_fun_name = String.to_atom("create_#{model.name()}")
      bulk_fun_name = String.to_atom("create_#{model.plural()}")

      quote location: :keep do
        def unquote(bulk_fun_name)(items, context \\ %{}) when is_list(items) do
          repo = repo()

          with {:ok, :ok} <-
                 repo.transaction(fn ->
                   items
                   |> Enum.reduce_while(nil, fn item, _ ->
                     case unquote(single_fun_name)(item, context) do
                       {:ok, _} ->
                         {:cont, :ok}

                       {:error, _} = error ->
                         {:halt, error}
                     end
                   end)
                   |> then(fn
                     :ok -> :ok
                     {:error, reason} -> repo.rollback(reason)
                   end)
                 end),
               do: :ok
        end
      end
    end
  end
end
