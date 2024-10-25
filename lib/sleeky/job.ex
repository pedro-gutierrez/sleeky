defmodule Sleeky.Job do
  @moduledoc """
  Generates function to schedule background jobs on different model actions
  """
  use Oban.Worker, queue: :default

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
    do_perform(job, model, id, task)
  rescue
    e ->
      reason = Exception.format(:error, e, __STACKTRACE__)
      handle_error(job, model, id, task, reason)
  end

  defp do_perform(job, model, id, task) do
    opts = [preload: model.parent_field_names()]

    case id |> model.fetch!(opts) |> task.execute() do
      {:error, reason} -> handle_error(job, model, id, task, reason)
      _ -> :ok
    end
  end

  defp handle_error(_job, model, id, task, reason) do
    Logger.warning("task failed", task: task, model: model, id: id, reason: inspect(reason))
    {:error, reason}
  end
end
