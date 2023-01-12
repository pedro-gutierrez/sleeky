defmodule Bee.Views.Parents do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(_ui, views, _schema) do
    view = module(views, Parents)

    definition =
      {:aside, [class: "menu box is-shadowless"],
       [
         {:ul, [class: "menu-list"],
          {:slot, :items,
           [
             {:li, [],
              [
                {:a, [class: "", "x-bind:href": {:slot, :url}],
                 [
                   {:span, [], [{:slot, :label}]},
                   {:i, [class: "is-pulled-right fa-solid fa-arrow-right has-text-primary mr-1"],
                    []}
                 ]}
              ]}
           ]}}
       ]}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end
end
