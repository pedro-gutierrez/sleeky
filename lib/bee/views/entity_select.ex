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
       {:div, [class: "mt-3 control has-icons-left has-icons-right is-clearfix"],
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
          {:span, ["x-on:click": "slot:keywords = null", class: "icon is-right is-clickable"],
           [
             {:i, [class: "fa-solid fa-circle-xmark"], []}
           ]}
        ]},
       {:div, [class: "control"],
        [
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
                       "x-on:click": {:slot, :select},
                       class: "dropdown-item",
                       "x-text": "item.display"
                     ], []}}
                 ]}
              ]}
           ]}
        ]}
     ]}
  end
end
