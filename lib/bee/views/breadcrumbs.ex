defmodule Bee.Views.Breadcrumbs do
  @moduledoc false

  alias Bee.UI.View

  import Bee.Inspector
  import Bee.Views.Components

  def ast(_ui, views, schema) do
    view = module(views, Breadcrumbs)

    exceptions =
      schema.entities
      |> Enum.reject(& &1.breadcrumbs?())
      |> Enum.map_join(",", & &1.plural())

    definition =
      {:div, [{"data-mode", "nav"}, {"data-nav-except", exceptions}],
       [
         link("*", "/$collection", "collection"),
         link("show,edit,delete,newChild", "/$collection/$id", "id"),
         link("children", "/$collection/$id/$children", "children"),
         link("new", "/$collection/new", "new"),
         link("edit,delete", "/$collection/$id/$mode", "mode"),
         link("newChild", "/$collection/$id/$children/new", "new")
       ]}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition, view))
      end
    end
  end

  defp link(show, url, text) do
    {:span, [data(:show, show)],
     [
       {:a, [data(:text, text), data(:link, url)], []}
     ]}
  end
end
