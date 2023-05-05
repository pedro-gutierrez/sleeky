defmodule Bee.Views do
  @moduledoc false

  @generators [
    Bee.Views.Notifications,
    Bee.Views.Input,
    Bee.Views.EntitySelect,
    Bee.Views.Select,
    Bee.Views.Textarea,
    Bee.Views.Label,
    Bee.Views.Children,
    Bee.Views.Parents,
    Bee.Views.Table,
    Bee.Views.Form,
    Bee.Views.Forms,
    Bee.Views.Lists,
    Bee.Views.EntityChildrenLists,
    Bee.Views.EntityDetail,
    Bee.Views.NavBar,
    Bee.Views.Menu,
    Bee.Views.Breadcrumbs,
    Bee.Views.Entities
  ]

  import Bee.Inspector

  defmacro __using__(opts) do
    views = __CALLER__.module
    ui = views |> context() |> module(UI)
    schema = opts |> Keyword.fetch!(:schema) |> module()

    @generators
    |> Enum.map(& &1.ast(ui, views, schema))
    |> flatten()
  end
end
