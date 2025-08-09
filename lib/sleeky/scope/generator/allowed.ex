defmodule Sleeky.Scope.Generator.Allowed do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _opts) do
    quote do
      def allowed?(context), do: Sleeky.Scope.allowed?(__MODULE__, context)
    end
  end
end
