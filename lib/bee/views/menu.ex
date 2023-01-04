defmodule Bee.Views.Menu do
  @moduledoc false

  import Bee.Inspector
  alias Bee.Entity
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = module(views, Menu)
    definition = definition(ui, views, schema)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end

  defp definition(ui, views, schema) do
    nav_bar_view = navbar_view(ui, views)
    items = schema.entities() |> Enum.filter(&has_menu?/1) |> Enum.map(&nav_item/1)

    {:view, nav_bar_view,
     [
       {:items, items}
     ]}
  end

  defp navbar_view(_ui, views) do
    module(views, NavBar)
  end

  defp has_menu?(entity) do
    Enum.empty?(entity.parents) && Entity.action(:list, entity)
  end

  defp nav_item(entity) do
    [
      url: "#/#{entity.plural}",
      label: Inflex.pluralize(entity.label)
    ]
  end
end
