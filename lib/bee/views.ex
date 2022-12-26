defmodule Bee.Views do
  @moduledoc false

  @generators [
    Bee.Views.Forms,
    Bee.Views.Lists,
    Bee.Views.Menu
  ]

  import Bee.Inspector

  defmacro __using__(_opts) do
    views = __CALLER__.module
    ui = views |> context() |> module(UI)
    schema = views |> context() |> module(Schema)

    @generators
    |> Enum.map(& &1.ast(ui, views, schema))
    |> flatten()
  end
end
