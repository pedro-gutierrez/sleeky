defmodule Sleeky.JsonApi.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  @impl true
  def parse({:json_api, [], children}, _) do
    contexts = for {:context, [], [module]} <- children, do: module
    plugs = for {:plugs, [], plugs} <- children, do: plugs
    plugs = List.flatten(plugs)

    %Sleeky.JsonApi{plugs: plugs, contexts: contexts}
  end
end
