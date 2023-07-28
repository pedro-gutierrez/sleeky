defmodule Sleeki.Views.Menu do
  @moduledoc false

  alias Sleeki.Entity
  alias Sleeki.UI.View

  import Sleeki.Inspector

  def ast(_ui, views, schema) do
    view = module(views, Menu)
    menu_container = module(views, MenuContainer)
    menu_item = module(views, MenuItem)

    definition =
      {:view, menu_container,
       [
         items:
           schema.entities()
           |> Enum.filter(&Entity.action(:list, &1))
           |> Enum.map(fn entity ->
             {:view, menu_item,
              [
                {:link, "/#{entity.plural()}"},
                {:label, entity.plural_label()}
              ]}
           end)
       ]}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition, view))
      end
    end
  end
end
