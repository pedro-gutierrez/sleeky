defmodule Sleeky.Feature.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Feature
  import Sleeky.Naming

  @impl true
  def parse({:feature, _, children}, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)
    name = name(caller_module)
    repo = repo(caller_module)
    app = app(caller_module)

    %Feature{name: name, repo: repo, app: app}
    |> with_modules(children, :scopes)
    |> with_modules(children, :models)
    |> with_modules(children, :commands)
    |> with_modules(children, :handlers)
  end

  defp with_modules(feature, children, kind) do
    mods = for {^kind, _, mods} <- children, do: mods
    mods = List.flatten(mods)

    Map.put(feature, kind, mods)
  end
end
