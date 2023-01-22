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
    {:div, [class: "field", "x-data": "{ filter: null, modifying: false, items: [] }"],
     [
       {:label, [class: "label"], [{:slot, :label}]},
       {:div, ["x-show": "!modifying"],
        [
          {:span,
           [
             "x-text":
               "item.{{ name }} ? ( item.{{ name }}.display || item.{{ name }}.id ) : 'No selection'"
           ], []},
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
             "x-on:input.debounce":
               "({items, messages} = await search_items('{{ entity }}', filter))",
             "x-model": "filter",
             placeholder: "Search {{ entity }} ",
             autocomplete: "off",
             "aria-autocomplete": "list"
           ], []},
          {:span, [class: "icon is-left"],
           [
             {:i, [class: "fa-solid fa-magnifying-glass"], []}
           ]},
          {:span,
           [
             "x-on:click": "filter = null; modifying = false",
             class: "icon is-right is-clickable"
           ],
           [
             {:i, [class: "fa-solid fa-circle-xmark"], []}
           ]}
        ]},
       {:div,
        [
          "x-bind:class": "filter ? 'is-active' : ''",
          class: "dropdown is-block"
        ],
        [
          {:div, [class: "dropdown-menu", role: "menu"],
           [
             {:div, [class: "dropdown-content"],
              [
                {:each, "items",
                 {:a,
                  [
                    tabindex: 0,
                    "x-on:click": "item.{{ name }} = i; filter = null; modifying = false",
                    class: "is-clickable dropdown-item",
                    "x-text": "i.display"
                  ], []}}
              ]}
           ]}
        ]}
     ]}
  end
end
