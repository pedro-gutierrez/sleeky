defmodule Sleeky.Domain.Generator.UpdateActions do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(domain, _) do
    for model <- domain.models, action when action.name == :update <- model.actions() do
      model_name = model.name()
      action_fun_name = String.to_atom("update_#{model_name}")
      do_action_fun_name = String.to_atom("do_update_#{model_name}")
      tasks = for task <- action.tasks, do: {task.module, task.if}

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

            with :ok <- allow(unquote(model_name), unquote(action.name), context) do
              unquote(model).edit(model, fields)
            end
          end
        end

      fun_with_map_args =
        quote do
          def unquote(action_fun_name)(model, attrs, context \\ %{})

          def unquote(action_fun_name)(model, attrs, context) when is_map(attrs) do
            context = attrs |> Map.merge(context) |> Map.put(unquote(model_name), model)
            repo = repo()

            repo.transaction(fn ->
              with {:ok, updated} <- unquote(do_action_fun_name)(model, attrs, context),
                   tasks <- tasks_to_execute(unquote(tasks), model, updated, context),
                   :ok <- Sleeky.Job.schedule_all(updated, :update, tasks) do
                updated
              else
                {:error, reason} ->
                  repo.rollback(reason)
              end
            end)
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
