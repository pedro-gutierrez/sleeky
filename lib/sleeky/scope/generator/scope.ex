defmodule Sleeky.Scope.Generator.Scope do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _opts) do
    quote do
      def scope(model, context), do: Sleeky.Scope.scope(__MODULE__, model, context)
    end
  end
end
