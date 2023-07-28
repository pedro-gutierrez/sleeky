defmodule Sleeki.Views do
  @moduledoc false

  @generators [
    Sleeki.Views.Forms,
    Sleeki.Views.Lists,
    Sleeki.Views.EntityDetail,
    Sleeki.Views.NavBar,
    Sleeki.Views.Menu,
    Sleeki.Views.Breadcrumbs,
    Sleeki.Views.Entities
  ]

  import Sleeki.Inspector

  defmacro __using__(opts) do
    views = __CALLER__.module
    ui = views |> context() |> module(UI)
    schema = opts |> Keyword.fetch!(:schema) |> module()

    @generators
    |> Enum.map(& &1.ast(ui, views, schema))
    |> flatten()
  end

  def pickup_view(rel, views) do
    pickup_view = module(views, PickUp)
    scope = rel.target.module.plural()
    {:view, pickup_view, [scope: scope, name: rel.name]}
  end
end
