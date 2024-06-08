defmodule Sleeky.Context.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  import Sleeky.Naming
  alias Sleeky.Context

  import Diesel, only: [children: 2, child: 2, child: 1]

  @impl true
  def parse(context, definition) do
    name = name(context)
    models = definition |> children(:model) |> child()
    authorization = definition |> child(:authorization) |> child()
    repo = repo(context)

    %Context{name: name, authorization: authorization, repo: repo, models: models}
  end
end
