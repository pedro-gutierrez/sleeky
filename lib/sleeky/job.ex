defmodule Sleeky.Job do
  @moduledoc """
  Generates function to schedule background jobs
  """
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Sleeky.Job.Worker

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
      handle_success(subscription)
      :ok
    else
      {:error, reason} -> handle_error(reason, event, subscription, job)
    end
  rescue
    e ->
      reason = Exception.format(:error, e, __STACKTRACE__)
      handle_error(reason, event, subscription, job)
  end

  defp handle_error(reason, event, subscription, job) do
    attempts_left = job.max_attempts - job.attempt
    level = if attempts_left == 0, do: :error, else: :warning

    Logger.log(level, "subscription failed",
      event: event,
      subscription: subscription,
      reason: format_error(reason),
      attempt: job.attempt,
      attempts_left: attempts_left
    )

    {:error, reason}
  end

  defp handle_success(subscription) do
    Logger.debug("subscription succeeded",
      subscription: subscription
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
