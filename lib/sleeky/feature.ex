defmodule Sleeky.Feature do
  @moduledoc false
  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Feature.Dsl,
    parsers: [
      Sleeky.Feature.Parser
    ],
    generators: [
      Sleeky.Feature.Generator.Metadata,
      Sleeky.Feature.Generator.Roles,
      Sleeky.Feature.Generator.Graph,
      Sleeky.Feature.Generator.Helpers,
      Sleeky.Feature.Generator.CreateFunctions,
      Sleeky.Feature.Generator.UpdateFunctions,
      Sleeky.Feature.Generator.Commands,
      Sleeky.Feature.Generator.Queries
    ]

  defstruct [
    :app,
    :name,
    :repo,
    scopes: [],
    models: [],
    handlers: [],
    commands: [],
    queries: [],
    events: [],
    subscriptions: [],
    values: []
  ]

  @doc """
  Executes a command, publishes events, and returns a result
  """
  def execute(command, params, context) do
    if command.atomic?() do
      repo = command.feature().repo()

      repo.transaction(fn ->
        with {:error, reason} <- do_execute(command, params, context) do
          repo.rollback(reason)
        end
      end)
    else
      do_execute(command, params, context)
    end
  end

  defp do_execute(command, params, context) do
    with {:ok, params} <- command.params().validate(params),
         context <- Map.put(context, :params, params),
         :ok <- allow(command, context),
         {:ok, result, events} <- command.execute(params, context),
         :ok <- publish_events(events, command) do
      {:ok, result}
    end
  end

  defp allow(command, context) do
    if command.allowed?(context) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  defp publish_events([], _command), do: :ok

  defp publish_events(events, command) do
    app = command.feature().app()

    events
    |> Enum.flat_map(&jobs(&1, app))
    |> IO.inspect(label: "publish_events")
    |> Sleeky.Job.schedule_all()

    :ok
  end

  defp jobs(event, app) do
    app.features()
    |> Enum.flat_map(& &1.subscriptions())
    |> Enum.filter(&(&1.event() == event.__struct__))
    |> Enum.map(&[event: event.__struct__, params: Jason.encode!(event), subscription: &1])
  end
end
