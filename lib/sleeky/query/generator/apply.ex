defmodule Sleeky.Query.Generator.Apply do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_query, _opts) do
    quote do
      def apply_filters(query, params), do: Sleeky.Query.apply_filters(__MODULE__, query, params)
      def apply_sorting(query), do: Sleeky.Query.apply_sorting(__MODULE__, query)
    end
  end
end
