defmodule Sleeky.Query.Generator.Handle do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_query, _opts) do
    quote do
      def handle(q, _params, _context), do: q
      def handle(q, _context), do: q

      defoverridable handle: 2, handle: 3
    end
  end
end
