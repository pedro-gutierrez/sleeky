defmodule Sleeky.App.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.App

  @impl true
  def parse({:app, attrs, children}, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)

    roles =
      attrs
      |> Keyword.fetch!(:roles)
      |> String.split(".")
      |> Enum.map(&String.to_atom/1)

    repos = for {:repos, _, repos} <- children, do: repos
    endpoints = for {:endpoints, _, endpoints} <- children, do: endpoints
    features = for {:features, _, features} <- children, do: features

    repos = List.flatten(repos)
    endpoints = List.flatten(endpoints)
    features = List.flatten(features)

    name = caller_module |> Module.split() |> Enum.drop(-1) |> Module.concat()

    repos = if repos == [], do: [Module.concat(name, Repo)], else: repos
    endpoints = if endpoints == [], do: [Module.concat(name, Endpoint)], else: endpoints

    %App{
      name: name,
      roles: roles,
      module: caller_module,
      repos: repos,
      endpoints: endpoints,
      features: features
    }
  end
end
