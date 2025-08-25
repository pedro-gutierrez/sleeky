defmodule Sleeky.Feature.Generator.Map do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _) do
    quote location: :keep do
      def map(from, to, input), do: Sleeky.Feature.map(__MODULE__, from, to, input)
    end
  end
end
