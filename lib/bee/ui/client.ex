defmodule Bee.UI.Client do
  @moduledoc false

  import Bee.Inspector
  import Bee.UI.Client.Helpers

  @generators [
    Bee.UI.Client.Store
  ]

  def ast(ui, _views, schema) do
    client = module(ui, Client)

    source =
      @generators
      |> Enum.map(& &1.ast(schema))
      |> flatten()
      |> Enum.map(&render/1)

    quote do
      defmodule unquote(client) do
        def source do
          unquote(source)
        end
      end
    end
  end
end
