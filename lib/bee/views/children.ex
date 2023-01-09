defmodule Bee.Views.Children do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(_ui, views, _schema) do
    view = module(views, Children)

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
                   {:span,
                    [
                      class: "is-pulled-right tag is-primary is-rounded",
                      "x-text": {:slot, :count}
                    ], []}
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
