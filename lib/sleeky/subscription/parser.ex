defmodule Sleeky.Subscription.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Subscription

  import Sleeky.Feature.Naming

  def parse({:subscription, attrs, _children}, opts) do
    name = Keyword.fetch!(opts, :caller_module)
    caller = Keyword.fetch!(opts, :caller_module)
    feature = feature_module(caller)

    event = Keyword.fetch!(attrs, :on)
    action = Keyword.get(attrs, :perform)

    %Subscription{
      name: name,
      feature: feature,
      event: event,
      action: action
    }
  end
end
