defmodule Sleeky.Subscription.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(subscription, _opts) do
    quote do
      def event, do: unquote(subscription.event)
      def action, do: unquote(subscription.action)
      def feature, do: unquote(subscription.feature)
      def name, do: unquote(subscription.name)
    end
  end
end
