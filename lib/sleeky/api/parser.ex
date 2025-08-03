defmodule Sleeky.Api.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  @impl true
  def parse({:api, [], children}, _) do
    features = for {:features, [], [module]} <- children, do: module
    features = List.flatten(features)

    plugs = for {:plugs, [], plugs} <- children, do: plugs
    plugs = List.flatten(plugs)

    %Sleeky.Api{plugs: plugs, features: features}
  end
end
