defmodule Sleeky.Feature.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _) do
    # scopes = for scopes <- feature.scopes, do: scopes.scopes()
    # scopes = Enum.reduce(scopes, %{}, &Map.merge/2)

    quote do
      import Ecto.Query

      @repo unquote(feature.repo)

      def app, do: unquote(feature.app)
      def name, do: unquote(feature.name)
      def models, do: unquote(feature.models)
      def repo, do: @repo
      # def scopes, do: unquote(Macro.escape(scopes))
    end
  end
end
