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
    {:div, [class: "field", "x-data": "{ 'modifying': false }"],
     [
       {:label, [class: "label"], [{:slot, :label}]},
       {:div, ["x-show": "!modifying"],
        [
          {:span, ["x-text": {:slot, :value}], []},
          {:button,
           [
             class: "button is-rounded is-light is-small ml-2",
             "x-show": "!modifying",
             "x-on:click": "modifying = !modifying"
           ], ["Change"]}
        ]},
       {:div,
        ["x-show": "modifying", class: "mt-3 control has-icons-left has-icons-right is-clearfix"],
        [
          {:input,
           [
             type: "text",
             class: "input is-light is-rounded",
             "x-on:input.debounce": {:slot, :search},
             "x-model": {:slot, :keywords},
             placeholder: {:slot, :placeholder},
             autocomplete: "off",
             "aria-autocomplete": "list"
           ], []},
          {:span, [class: "icon is-left"],
           [
             {:i, [class: "fa-solid fa-magnifying-glass"], []}
           ]},
          {:span,
           [
             "x-on:click": "slot:keywords = null; modifying = false",
             class: "icon is-right is-clickable"
           ],
           [
             {:i, [class: "fa-solid fa-circle-xmark"], []}
           ]}
        ]},
       {:div,
        [
          "x-bind:class": "slot:keywords ? 'is-active' : ''",
          class: "dropdown is-block"
        ],
        [
          {:div, [class: "dropdown-menu", role: "menu"],
           [
             {:div, [class: "dropdown-content"],
              [
                {:loop, {:slot, :results},
                 {:a,
                  [
                    href: "#",
                    tabindex: 0,
                    "x-on:click": "slot:select ; modifying = false",
                    class: "dropdown-item",
                    "x-text": "item.display"
                  ], []}}
              ]}
           ]}
        ]}
     ]}
  end
end
