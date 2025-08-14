defmodule Sleeky.Flow do
  @moduledoc false

  use Diesel,
    otp_app: :sleeky,
    dsl: Sleeky.Flow.Dsl,
    parser: Sleeky.Flow.Parser,
    generators: [
      Sleeky.Flow.Generator.Metadata,
      Sleeky.Flow.Generator.Execute
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
      |> Enum.map(&[command: &1.command, params: params, flow: flow])
      |> Sleeky.Job.schedule_all()

      {:ok, model}
    end
  end

  defp to_plain_map(data) when is_struct(data), do: Map.from_struct(data)
  defp to_plain_map(data) when is_map(data), do: data
end
