defmodule Sleeky.Context.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_context, context) do
    quote do
      import Ecto.Query

      def name, do: unquote(context.name)
      def models, do: unquote(context.models)
      def repo, do: unquote(context.repo)
    end
  end
end
