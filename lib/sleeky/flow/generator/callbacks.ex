defmodule Sleeky.Flow.Generator.Callbacks do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_flow, _opts) do
    quote location: :keep do
      def step_completed(id, step), do: Sleeky.Flow.step_completed(__MODULE__, id, step)
    end
  end
end
