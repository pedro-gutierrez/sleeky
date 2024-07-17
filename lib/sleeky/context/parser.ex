defmodule Sleeky.Context.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  import Sleeky.Naming
  alias Sleeky.Context

  import Diesel, only: [children: 2, child: 2, child: 1]

  @impl true
  def parse(definition, opts) do
    caller_module = Keyword.fetch!(opts, :caller_module)

    name = name(caller_module)
    repo = repo(caller_module)
    models = definition |> children(:model) |> child()
    authorization = definition |> child(:authorization) |> child()

    %Context{name: name, authorization: authorization, repo: repo, models: models}
  end
end
