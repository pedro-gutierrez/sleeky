defmodule Bee.Views.EntitySelect do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = module(views, EntitySelect)
    definition = definition(ui, schema)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end

  defp definition(_ui, _schema) do
    {:div, [class: "field"],
     [
       {:label, [class: "label"], [{:slot, :label}]},
       {:span, ["x-text": {:slot, :value}], []},
       {:div, [class: "mt-3 control has-icons-right"],
        [
          {:input,
           [
             type: "text",
             class: "input is-light",
             "x-model": {:slot, :filter},
             placeholder: {:slot, :placeholder}
           ], []},
          {:span, ["x-on:click": "slot:filter = null", class: "icon is-right is-clickable"],
           [
             {:i, [class: "fa-solid fa-circle-xmark"], []}
           ]}
        ]},
       {:div, [class: "control"],
        [
          {:div,
           [
             "x-bind:class": "slot:filter ? 'is-active' : ''",
             class: "dropdown is-block"
           ],
           [
             {:div, [class: "dropdown-menu", role: "menu"],
              [
                {:div, [class: "dropdown-content"],
                 [
                   {:a, [href: "#", class: "dropdown-item"],
                    [
                      "John Chrichton"
                    ]},
                   {:a, [href: "#", class: "dropdown-item"],
                    [
                      "Kar Dhargo"
                    ]},
                   {:a, [href: "#", class: "dropdown-item"],
                    [
                      "Aeryn Sun"
                    ]}
                 ]}
              ]}
           ]}
        ]}
     ]}
  end
end
