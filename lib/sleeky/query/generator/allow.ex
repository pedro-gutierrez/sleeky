defmodule Sleeky.Query.Generator.Allow do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_query, _opts) do
    quote do
      def allowed?(context), do: Sleeky.Query.Helper.allowed?(__MODULE__, context)
    end
  end
end
