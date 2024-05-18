defmodule Sleeky.Context.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Naming
  alias Sleeky.Context

  import Diesel, only: [children: 2, child: 2, child: 1]

  @impl true
  def parse(context, definition) do
    name = Naming.name(context)
    models = definition |> children(:model) |> child()
    authorization = definition |> child(:authorization) |> child()
    repo = repo(definition, context)

    %Context{name: name, authorization: authorization, repo: repo, models: models}
  end

  defp repo(_, context) do
    context
    |> Module.split()
    |> Enum.drop(-1)
    |> Kernel.++([Repo])
    |> Module.concat()
  end
end
