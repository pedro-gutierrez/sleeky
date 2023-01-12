defmodule Bee.Views do
  @moduledoc false

  @generators [
    Bee.Views.Notifications,
    Bee.Views.Input,
    Bee.Views.Select,
    Bee.Views.Textarea,
    Bee.Views.Label,
    Bee.Views.Detail,
    Bee.Views.Children,
    Bee.Views.Parents,
    Bee.Views.Table,
    Bee.Views.Form,
    Bee.Views.Forms,
    Bee.Views.Lists,
    Bee.Views.EntityDetail,
    Bee.Views.NavBar,
    Bee.Views.Menu,
    Bee.Views.Breadcrumbs,
    Bee.Views.Entities
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
