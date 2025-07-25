defmodule Sleeky.App.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.App

  @impl true
  def parse({:app, _, children}, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)

    repos = for {:repos, _, repos} <- children, do: repos
    endpoints = for {:endpoints, _, endpoints} <- children, do: endpoints
    domains = for {:domains, _, domains} <- children, do: domains

    repos = List.flatten(repos)
    endpoints = List.flatten(endpoints)
    domains = List.flatten(domains)

    name = caller_module |> Module.split() |> Enum.drop(-1) |> Module.concat()

    repos = if repos == [], do: [Module.concat(name, Repo)], else: repos
    endpoints = if endpoints == [], do: [Module.concat(name, Endpoint)], else: endpoints

    %App{
      name: name,
      module: caller_module,
      repos: repos,
      endpoints: endpoints,
      domains: domains
    }
  end
end
