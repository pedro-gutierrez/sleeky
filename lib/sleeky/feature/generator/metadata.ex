defmodule Sleeky.Feature.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _) do
    quote do
      import Ecto.Query

      @repo unquote(feature.repo)

      def name, do: unquote(feature.name)
      def models, do: unquote(feature.models)
      def repo, do: @repo
    end
  end
end
