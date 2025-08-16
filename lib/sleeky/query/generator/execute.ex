defmodule Sleeky.Query.Generator.Execute do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_query, _opts) do
    quote do
      def execute(q, _params, _context), do: q
      def execute(q, _context), do: q

      defoverridable execute: 2, execute: 3
    end
  end
end
