defmodule Sleeky.Job do
  @moduledoc """
  Generates function to schedule background jobs on different model actions
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Sleeky.Job.Worker

  def schedule_all(_model, _action, []), do: :ok

  def schedule_all(model, action, jobs) do
    with [_ | _] <-
           jobs
           |> Enum.map(&new(%{model: model.__struct__, id: model.id, action: action, task: &1}))
           |> Oban.insert_all(),
         do: :ok
  end

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"model" => model, "id" => id, "task" => task}} = job) do
    model = Module.concat([model])
    task = Module.concat([task])
    repo = model.repo()

    with {:ok, :ok} <-
           repo.transaction(fn ->
             with {:error, reason} <- do_perform(model, id, task) do
               log_error(job, model, id, task, reason)
               repo.rollback(reason)
             end
           end),
         do: :ok
  rescue
    e ->
      reason = Exception.format(:error, e, __STACKTRACE__)
      handle_error(job, model, id, task, reason)
  end

  defp do_perform(model, id, task) do
    opts = [preload: model.parent_field_names()]

    case id |> model.fetch!(opts) |> task.execute() do
      {:error, _} = error -> error
      _ -> :ok
    end
  end

  defp handle_error(job, model, id, task, reason) do
    log_error(job, model, id, task, reason)
    {:error, reason}
  end

  defp log_error(job, model, id, task, reason),
    do:
      Logger.warning("task failed",
        task: task,
        model: model,
        id: id,
        queue: job.queue,
        reason: format_error(reason),
        attempts_left: job.max_attempts - job.attempt
      )

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
