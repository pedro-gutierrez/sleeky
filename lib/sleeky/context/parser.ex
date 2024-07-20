defmodule Sleeky.Context.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  import Sleeky.Naming
  alias Sleeky.Context

  @impl true
  def parse({:context, _, children}, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)

    name = name(caller_module)
    repo = repo(caller_module)

    models = for {:model, _, [model]} <- children, do: model

    authorization = for {:authorization, _, [authorization]} <- children, do: authorization
    authorization = List.first(authorization)

    %Context{name: name, authorization: authorization, repo: repo, models: models}
  end
end
