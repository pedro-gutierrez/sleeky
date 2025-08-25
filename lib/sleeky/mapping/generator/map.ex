defmodule Sleeky.Mapping.Generator.Transform do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_mapping, _opts) do
    quote do
      def map(source_data), do: Sleeky.Mapping.map(__MODULE__, source_data)
    end
  end
end
