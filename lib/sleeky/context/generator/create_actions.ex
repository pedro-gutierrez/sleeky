defmodule Sleeky.Context.Generator.CreateActions do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(context, _) do
    create_funs(context) ++ do_create_funs(context) ++ create_children_funs(context)
  end

  defp create_funs(context) do
    for model <- context.models, %{name: :create} = action <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("create_#{model_name}")
      do_action_fun_name = String.to_atom("do_create_#{model_name}")
      children_action_fun_name = String.to_atom("create_#{model_name}_children")
      tasks = action.tasks

      quote do
        def unquote(action_fun_name)(attrs, context \\ %{}) do
          context = Map.merge(attrs, context)
          repo = repo()

          repo.transaction(fn ->
            with {:ok, model} <- unquote(do_action_fun_name)(attrs, context),
                 :ok <- unquote(children_action_fun_name)(model, attrs, context),
                 :ok <- Sleeky.Job.schedule_all(model, :create, unquote(tasks)) do
              model
            else
              {:error, reason} ->
                repo.rollback(reason)
            end
          end)
        end
      end
    end
  end

  defp do_create_funs(context) do
    for model <- context.models, %{name: :create} = action <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("do_create_#{model_name}")

      attr_names =
        for attr when not attr.computed? <- model.attributes(),
            do: attr.name

      parent_fields =
        for rel when not rel.computed? <- model.parents(),
            into: %{},
            do: {rel.name, rel.column_name}

      quote do
        defp unquote(action_fun_name)(attrs, context) do
          fields =
            attrs
            |> Map.take(unquote(attr_names))
            |> collect_ids(attrs, unquote(Macro.escape(parent_fields)))

          with :ok <- allow(unquote(model_name), unquote(action.name), context) do
            unquote(model).create(fields)
          end
        end
      end
    end
  end

  defp create_children_funs(context) do
    for model <- context.models, %{name: :create} <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("create_#{model_name}_children")

      child_fields =
        for rel when not rel.computed? <- model.children(),
            do: {rel.name, rel.inverse.name, String.to_atom("create_#{rel.target.name}")}

      quote do
        defp unquote(action_fun_name)(model, attrs, context) do
          context = Map.put(context, unquote(model_name), model)

          unquote(Macro.escape(child_fields))
          |> Enum.reduce([], fn {child_name, inverse_name, create_fun_name}, acc ->
            case Map.get(attrs, child_name) do
              children when is_list(children) ->
                Enum.map(children, &{Map.put(&1, inverse_name, model), create_fun_name})

              nil ->
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
end
