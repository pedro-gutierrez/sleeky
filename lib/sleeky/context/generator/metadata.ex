defmodule Sleeky.Context.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(context, _) do
    quote do
      import Ecto.Query

      @repo unquote(context.repo)

      def name, do: unquote(context.name)
      def models, do: unquote(context.models)
      def repo, do: @repo
    end
  end
end
