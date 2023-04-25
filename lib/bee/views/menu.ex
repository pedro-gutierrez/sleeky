defmodule Bee.Views.Menu do
  @moduledoc false

  alias Bee.Entity
  alias Bee.UI.View

  import Bee.Inspector
  import Bee.Views.Components

  def ast(_ui, views, schema) do
    view = module(views, Menu)
    items = schema.entities() |> Enum.filter(&has_menu?/1) |> Enum.map(&menu_item_view/1)
    definition = {:div, [data(:mode, :nav)], items}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end

  defp menu_item_view(entity) do
    link_view("/#{entity.plural()}", entity.plural_label())
  end

  defp has_menu?(entity), do: Entity.action(:list, entity)
end
