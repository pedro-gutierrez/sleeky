defmodule Bee.Views.Breadcrumbs do
  @moduledoc false

  alias Bee.UI.View

  import Bee.Inspector
  import Bee.Views.Components

  def ast(_ui, views, _schema) do
    view = module(views, Breadcrumbs)

    definition =
      {:div, [mode("nav")],
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
        unquote(View.ast(definition))
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
