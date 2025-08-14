defmodule Sleeky.Flow do
  @moduledoc false

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Flow.Dsl,
    parser: Sleeky.Flow.Parser,
    generators: [
      Sleeky.Flow.Generator.Callbacks,
      Sleeky.Flow.Generator.Execute,
      Sleeky.Flow.Generator.Metadata
    ]

  defstruct [:fun_name, :create_model_fun_name, :feature, :model, :params, :event, :steps]

  defmodule Step do
    @moduledoc false
    defstruct [:name, :command]
  end

  @doc """
  Execute the given flow, with the given parameters and context.
  """
  def execute(flow, params, _context) do
    feature = flow.feature()
    create_model_fun_name = flow.create_model_fun_name()
    count = flow.steps() |> Enum.count()
    attrs = params |> to_plain_map() |> Map.put(:steps_pending, count)

    with {:ok, model} <- apply(feature, create_model_fun_name, [attrs]) do
      params = Jason.encode!(params)

      flow.steps()
      |> Enum.map(&[command: &1.command, params: params, flow: flow, id: model.id])
      |> Sleeky.Job.schedule_all()

      {:ok, model}
    end
  end

  defp to_plain_map(data) when is_struct(data), do: Map.from_struct(data)
  defp to_plain_map(data) when is_map(data), do: data

  @doc """
  Mark a step as completed.
  """
  def step_completed(flow, id, step) do
    with 0 <- decrement_steps_pending(flow, id),
         model <- flow.model(),
         event = flow.event(),
         mapping = flow.feature().mapping!(model, event),
         {:ok, input} <- model.fetch(id),
         {:ok, event} <- mapping.map(input) do
      Sleeky.Feature.publish_events([event], step.feature())
    else
      n when n > 0 -> :ok
      {:error, _} = error -> error
    end
  end

  import Ecto.Query

  defp decrement_steps_pending(flow, id) do
    repo = flow.feature().repo()
    model = flow.model()

    case model
         |> where([m], m.id == ^id)
         |> select([m], m.steps_pending)
         |> repo.update_all(inc: [steps_pending: -1]) do
      {1, [steps_pending]} -> steps_pending
      {0, _} -> {:error, :flow_not_found}
      {n, _} -> {:error, {:too_many_flows, n}}
    end
  end
end
