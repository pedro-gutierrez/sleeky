defmodule Sleeky.Job do
  @moduledoc """
  Generates function to schedule background jobs on different model actions
  """

  alias Sleeky.Job.Worker

  def schedule_all(_model, _action, []), do: :ok

  def schedule_all(model, action, jobs) do
    with [_ | _] <-
           jobs
           |> Enum.map(&worker(model, action, &1))
           |> Oban.insert_all(),
         do: :ok
  end

  defp worker(model, action, job) do
    Worker.new(%{model: model.__struct__, id: model.id, action: action, job: job})
  end
end
