defmodule Sleeky.Views.NavBar do
  @moduledoc false

  import Sleeky.Inspector
  alias Sleeky.UI.View

  def ast(ui, views, schema) do
    view = module(views, NavBar)
    definition = definition(ui, schema)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition, view))
      end
    end
  end

  defp definition(_ui, _schema) do
    [
      {:div, [class: "navbar-start"],
       [
         {:slot, :items,
          [
            {:a, [class: "navbar-item", href: {:slot, :url}],
             [
               {:span, [], [{:slot, :label}]}
             ]}
          ]}
       ]},
      {:div, [class: "navbar-end"],
       [
         {:div, [class: "navbar-item"], []}
       ]}
    ]
  end
end
