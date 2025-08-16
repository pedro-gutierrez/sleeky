defmodule Sleeky.Feature.Generator.Helpers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _) do
    quote location: :keep do
      import Sleeky.Feature.Helpers

      def mapping!(from, to), do: Sleeky.Feature.mapping!(__MODULE__, from, to)
    end
  end
end
