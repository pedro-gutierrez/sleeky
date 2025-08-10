defmodule Sleeky.Feature.Generator.Subscriptions do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _opts) do
    subscriptions = get_subscriptions(feature)

    quote do
      def subscriptions, do: unquote(subscriptions)
    end
  end

  defp get_subscriptions(feature) do
    feature.subscriptions || []
  end
end
