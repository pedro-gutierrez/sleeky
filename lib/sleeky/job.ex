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
           |> Enum.map(&new(%{model: model.__struct__, id: model.id, action: action, job: &1}))
           |> Oban.insert_all(),
         do: :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"model" => model, "id" => id, "job" => job}}) do
    model = Module.concat([model])
    job = Module.concat([job])

    with {:ok, model} <- model.fetch(id) do
      job.execute(model)
    end
  end
end
