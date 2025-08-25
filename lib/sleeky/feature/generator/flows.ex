defmodule Sleeky.Feature.Generator.Flows do
  @moduledoc false

  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _opts) do
    for flow <- feature.flows do
      fun_name = flow.fun_name()

      quote location: :keep do
        def unquote(fun_name)(params, context \\ %{}),
          do: Sleeky.Flow.execute(unquote(flow), params, context)
      end
    end
  end
end
