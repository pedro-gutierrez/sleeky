defmodule Sleeky.Feature.Generator.Events do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(feature, _opts) do
    events = get_events(feature)

    quote do
      def events, do: unquote(events)
    end
  end

  defp get_events(feature) do
    feature.events || []
  end
end
