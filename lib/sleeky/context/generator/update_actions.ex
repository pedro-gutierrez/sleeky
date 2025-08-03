defmodule Sleeky.Context.Generator.UpdateActions do
  @moduledoc false
  @behaviour Diesel.Generator

  import Sleeky.Naming

  @impl true
  def generate(context, _) do
    for entity <- context.entities, action when action.name == :update <- entity.actions() do
      entity_name = entity.name()
      action_fun_name = String.to_atom("update_#{entity_name}")
      do_action_fun_name = String.to_atom("do_update_#{entity_name}")
      tasks = for task <- action.tasks, do: {task.module, task.if}

      attr_names =
        for attr when attr.mutable? and not attr.computed? <- entity.attributes(),
            do: attr.name

      parent_fields =
        for rel when rel.mutable? and not rel.computed? <- entity.parents(),
            into: %{},
            do: {rel.name, rel.column_name}

      do_update_fun =
        quote do
          defp unquote(do_action_fun_name)(entity, attrs, context) do
            fields =
              attrs
              |> Map.take(unquote(attr_names))
              |> collect_ids(attrs, unquote(Macro.escape(parent_fields)))

            with :ok <- allow(unquote(entity_name), unquote(action.name), context) do
              unquote(entity).edit(entity, fields)
            end
          end
        end

      fun_with_map_args =
        quote do
          def unquote(action_fun_name)(entity, attrs, context \\ %{})

          def unquote(action_fun_name)(entity, attrs, context) when is_map(attrs) do
            context = attrs |> Map.merge(context) |> Map.put(unquote(entity_name), entity)
            repo = repo()

            repo.transaction(fn ->
              with {:ok, updated} <- unquote(do_action_fun_name)(entity, attrs, context),
                   tasks <- tasks_to_execute(unquote(tasks), entity, updated, context),
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
          def unquote(action_fun_name)(entity, attrs, context) when is_list(attrs) do
            attrs = Map.new(attrs)

            unquote(action_fun_name)(entity, attrs, context)
          end
        end

      [do_update_fun, fun_with_map_args, fun_with_kw_args]
    end
  end
end
