defmodule Sleeky.Subscription.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Subscription

  import Sleeky.Feature.Naming

  def parse({:subscription, attrs, children}, opts) do
    name = Keyword.fetch!(opts, :caller_module)
    caller = Keyword.fetch!(opts, :caller_module)
    feature = feature_module(caller)

    event = Keyword.fetch!(attrs, :to)

    commands =
      for {:command, _, [command]} <- children do
        command
      end

    commands = List.flatten(commands)

    %Subscription{
      name: name,
      feature: feature,
      event: event,
      commands: commands
    }
  end
end
