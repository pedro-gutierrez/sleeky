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
    |> with_scopes(children)
    |> with_entities(children)
  end

  defp with_entities(context, children) do
    entities = for {:entities, _, entities} <- children, do: entities
    entities = List.flatten(entities)

    %{context | entities: entities}
  end

  defp with_scopes(context, children) do
    scopes = for {:scopes, _, [scopes]} <- children, do: scopes
    scopes = List.first(scopes)

    %{context | scopes: scopes}
  end
end
