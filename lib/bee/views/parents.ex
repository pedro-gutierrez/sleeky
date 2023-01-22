defmodule Bee.Views.Parents do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(_ui, views, _schema) do
    view = module(views, Parents)

    definition =
      {:div, [class: "block"],
       [
         {:slot, :items,
          [
            {:p, [],
             [
               {:a, [class: "button is-text", "x-bind:href": {:slot, :url}],
                [
                  {:span, [], [{:slot, :label}]}
                ]}
             ]}
          ]}
       ]}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end
end
