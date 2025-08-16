defmodule Sleeky.Flow.Generator.Execute do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_flow, _opts) do
    quote location: :keep do
      def execute(params, context \\ %{}), do: Sleeky.Flow.execute(__MODULE__, params, context)
    end
  end
end
