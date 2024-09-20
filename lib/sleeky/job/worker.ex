defmodule Sleeky.Job.Worker do
  @moduledoc """
  A generic Oban worker for model tasks
  """
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    IO.inspect(args: args)

    :ok
  end
end
