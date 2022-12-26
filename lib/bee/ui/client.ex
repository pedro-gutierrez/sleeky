defmodule Bee.UI.Client do
  @moduledoc false

  import Bee.Inspector
  import Bee.UI.Client.Helpers

  @generators [
    Bee.UI.Client.Router,
    Bee.UI.Client.Store
  ]

  def ast(ui, _views, schema) do
    client = module(ui, Client)

    source =
      @generators
      |> Enum.map(& &1.ast(schema))
      |> flatten()
      |> event_listener("alpine:init")
      |> render()

    quote do
      defmodule unquote(client) do
        def source do
          unquote(source)
        end
      end
    end
  end
end
