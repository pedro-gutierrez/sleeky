defmodule Bee.Views.Notifications do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = view_name(ui, views)
    definition = definition(ui, schema)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end

  defp view_name(_ui, views) do
    module(views, Notifications)
  end

  defp definition(_ui, _schema) do
    {:div, [class: "block notifications", "x-show": "messages.length"],
     {:each, "messages",
      {:div,
       [
         "x-bind:class": "`is-${i.severity}`",
         class: "notification is-light",
         "x-text": "i.text"
       ], []}}}
  end
end
