defmodule Sleeky.Job do
  @moduledoc """
  Generates function to schedule background jobs
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Sleeky.Error

  require Logger

  def schedule_all(jobs) do
    jobs = jobs |> Enum.map(&(&1 |> Map.new() |> new()))
    with [_ | _] <- Oban.insert_all(jobs), do: :ok
  end

  @impl Oban.Worker
  def perform(
        %{args: %{"event" => event, "params" => params, "subscription" => subscription}} = job
      ) do
    subscription = Module.concat([subscription])
    event = Module.concat([event])

    with {:ok, event} <- event.decode(params),
         {:ok, _} <- subscription.execute(event) do
      handle_success(subscription: subscription)
      :ok
    else
      {:error, reason} ->
        handle_error(job, reason, event: event, subscription: subscription)
    end
  rescue
    e ->
      reason = Exception.format(:error, e, __STACKTRACE__)
      handle_error(job, reason, event: event, subscription: subscription)
  end

  def perform(%{
        args: %{"command" => step, "params" => params, "flow" => flow} = job
      }) do
    flow = Module.concat([flow])
    step = Module.concat([step])

    IO.inspect(command: flow, step: step, params: params)
    handle_success(flow: flow)
    :ok

    # with {:ok, params} <- flow.decode(params),
    #      {:ok, _} <- step.execute(step) do
    #   handle_success(flow)
    #   :ok
    # else
    #   {:error, reason} -> handle_error(reason, step, flow, job)
    # end
  rescue
    e ->
      reason = Exception.format(:error, e, __STACKTRACE__)
      handle_error(job, reason, step: step, flow: flow)
  end

  defp handle_error(job, reason, meta) do
    attempts_left = job.max_attempts - job.attempt
    level = if attempts_left == 0, do: :error, else: :warning

    meta =
      Keyword.merge(meta,
        reason: Error.format(reason),
        attempt: job.attempt,
        attempts_left: attempts_left
      )

    Logger.log(level, "job failed", meta)

    {:error, reason}
  end

  defp handle_success(meta), do: Logger.debug("job succeeded", meta)
end
