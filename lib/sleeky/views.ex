defmodule Sleeky.Views do
  @moduledoc false

  @generators [
    Sleeky.Views.Forms,
    Sleeky.Views.Lists,
    Sleeky.Views.EntityDetail,
    Sleeky.Views.NavBar,
    Sleeky.Views.Menu,
    Sleeky.Views.Breadcrumbs,
    Sleeky.Views.Entities
  ]

  import Sleeky.Inspector

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
