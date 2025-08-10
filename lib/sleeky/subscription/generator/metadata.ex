defmodule Sleeky.Subscription.Generator.Metadata do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(subscription, _opts) do
    quote do
      def event, do: unquote(subscription.event)
      def command, do: unquote(subscription.command)
      def feature, do: unquote(subscription.feature)
      def name, do: unquote(subscription.name)
    end
  end
end
