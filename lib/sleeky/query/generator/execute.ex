defmodule Sleeky.Query.Generator.Execute do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_query, _opts) do
    quote do
      def execute(params, context) do
        if allowed?(context) do
          handler().execute(params, context)
        else
          {:error, :unauthorized}
        end
      end
    end
  end
end
