defmodule Sleeky.Feature.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _) do
    quote do
      import Ecto.Query

      @repo unquote(feature.repo)

      def repo, do: @repo
      def app, do: unquote(feature.app)
      def name, do: unquote(feature.name)

      def models, do: unquote(feature.models)
      def events, do: unquote(feature.events)
      def mappings, do: unquote(feature.mappings)
      def commands, do: unquote(feature.commands)
      def queries, do: unquote(feature.queries)
      def scopes, do: unquote(feature.scopes)
      def subscriptions, do: unquote(feature.subscriptions)
      def values, do: unquote(feature.values)
    end
  end
end
