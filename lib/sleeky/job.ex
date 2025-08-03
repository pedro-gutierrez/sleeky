defmodule Sleeky.Job do
  @moduledoc """
  Generates function to schedule background jobs on different entity actions
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Sleeky.Job.Worker

  def schedule_all(_entity, _action, []), do: :ok

  def schedule_all(entity, action, jobs) do
    with [_ | _] <-
           jobs
           |> Enum.map(
             &new(%{
               entity: entity.__struct__,
               id: entity.id,
               action: action,
               task: &1,
               atomic: false
             })
           )
           |> Oban.insert_all(),
         do: :ok
  end

  require Logger

  @impl Oban.Worker
  def perform(
        %Oban.Job{args: %{"entity" => entity, "id" => id, "task" => task, "atomic" => atomic}} =
          job
      ) do
    entity = Module.concat([entity])
    task = Module.concat([task])

    with {:ok, record} <- entity.fetch(id, preload: entity.parent_field_names()),
         :ok <- do_perform(record, task, atomic) do
      log_success(job, entity, id, task)

      :ok
    else
      {:error, reason} ->
        log_error(job, entity, id, task, reason)

        {:error, reason}
    end
  rescue
    e ->
      reason = Exception.format(:error, e, __STACKTRACE__)
      log_error(job, entity, id, task, reason)

      {:error, reason}
  end

  defp do_perform(%{__struct__: entity} = record, task, true) do
    repo = entity.repo()

    with {:ok, :ok} <-
           repo.transaction(fn ->
             with {:error, reason} <- do_perform(record, task) do
               repo.rollback(reason)
             end
           end),
         do: :ok
  end

  defp do_perform(record, task, false), do: do_perform(record, task)

  defp do_perform(record, task) do
    case task.execute(record) do
      {:error, _} = error -> error
      _ -> :ok
    end
  end

  defp log_error(job, entity, id, task, reason) do
    attempts_left = job.max_attempts - job.attempt
    level = if attempts_left == 0, do: :error, else: :warning

    Logger.log(level, "task failed",
      task: task,
      entity: entity,
      id: id,
      queue: job.queue,
      job: job.id,
      reason: format_error(reason),
      attempt: job.attempt,
      attempts_left: attempts_left
    )
  end

  defp log_success(_job, _entity, _id, task) do
    Logger.debug("task succeeded",
      task: task
    )
  end

  defp format_error(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> format_error()
  end

  defp format_error(error) when is_atom(error), do: to_string(error)
  defp format_error(error) when is_binary(error), do: error
  defp format_error(error), do: inspect(error)
end
