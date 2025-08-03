defmodule Sleeky.Api.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  @impl true
  def parse({:api, [], children}, _) do
    contexts = for {:contexts, [], [module]} <- children, do: module
    contexts = List.flatten(contexts)

    plugs = for {:plugs, [], plugs} <- children, do: plugs
    plugs = List.flatten(plugs)

    %Sleeky.Api{plugs: plugs, contexts: contexts}
  end
end
