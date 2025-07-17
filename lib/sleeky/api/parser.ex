defmodule Sleeky.Api.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  @impl true
  def parse({:api, [], children}, _) do
    domains = for {:domains, [], [module]} <- children, do: module
    domains = List.flatten(domains)

    plugs = for {:plugs, [], plugs} <- children, do: plugs
    plugs = List.flatten(plugs)

    %Sleeky.Api{plugs: plugs, domains: domains}
  end
end
