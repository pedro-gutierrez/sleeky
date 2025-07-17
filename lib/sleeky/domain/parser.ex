defmodule Sleeky.Domain.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Domain
  import Sleeky.Naming

  @impl true
  def parse({:domain, _, children}, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)

    %Domain{
      name: name(caller_module),
      repo: repo(caller_module)
    }
    |> with_scopes(children)
    |> with_models(children)
  end

  defp with_models(context, children) do
    models = for {:model, _, [model]} <- children, do: model

    %{context | models: models}
  end

  defp with_scopes(context, children) do
    scopes = for {:scopes, _, [scopes]} <- children, do: scopes
    scopes = List.first(scopes)

    %{context | scopes: scopes}
  end
end
