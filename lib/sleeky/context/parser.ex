defmodule Sleeky.Context.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Context
  import Sleeky.Naming

  @impl true
  def parse({:context, _, children}, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)

    %Context{
      name: name(caller_module),
      repo: repo(caller_module)
    }
    |> with_authorization(children)
    |> with_models(children)
  end

  defp with_models(context, children) do
    models = for {:model, _, [model]} <- children, do: model

    %{context | models: models}
  end

  defp with_authorization(context, children) do
    scopes = for {:scopes, _, [scopes]} <- children, do: scopes
    scopes = List.first(scopes)

    %{context | scopes: scopes}
  end
end
