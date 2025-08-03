defmodule Sleeky.Feature.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Feature
  import Sleeky.Naming

  @impl true
  def parse({:feature, _, children}, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)

    %Feature{
      name: name(caller_module),
      repo: repo(caller_module)
    }
    |> with_scopes(children)
    |> with_models(children)
  end

  defp with_models(feature, children) do
    models = for {:models, _, models} <- children, do: models
    models = List.flatten(models)

    %{feature | models: models}
  end

  defp with_scopes(feature, children) do
    scopes = for {:scopes, _, [scopes]} <- children, do: scopes
    scopes = List.first(scopes)

    %{feature | scopes: scopes}
  end
end
