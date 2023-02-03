defmodule Bee.Views.Table do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = module(views, Table)
    definition = definition(ui, schema)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end

  defp definition(_ui, _schema) do
    [
      {:div, [class: "box is-shadowless"],
       [
         {:div, [],
          [
            {:input,
             [
               type: "text",
               "x-model": {:slot, :search},
               "x-on:input.debounce": {:slot, :update},
               class: "input is-rounded is-light pl-3",
               placeholder: "Search"
             ], []}
          ]},
         {:div, [class: "p-3"],
          [
            {:span, ["x-show": "items.length == 0"], ["No items found"]},
            {:span, ["x-show": "items.length != 0", "x-text": "`Showing ${items.length} items`"],
             []},
            {:a,
             [
               class: "ml-2 has-text-primary",
               "x-bind:href": "`#/${$store.default.entity}/new`"
             ],
             [
               {:span, [], "Create new"}
             ]}
          ]},
         {:table,
          [
            "x-show": "items.length",
            class: "table is-fullwidth is-borderless is-hoverable mt-4"
          ],
          [
            {:thead, [],
             [
               {:tr, [],
                [
                  {:slot, :headers,
                   [
                     {:th, [], {:slot, :label}}
                   ]}
                ]}
             ]},
            {:tbody, [],
             [
               {:each, "items",
                [
                  {:tr,
                   [class: "is-clickable", "x-bind:onclick": "`window.location='{{ select }}';`"],
                   [
                     {:slot, :fields,
                      [
                        {:td, ["x-text": {:slot, :binding}], []}
                      ]}
                   ]}
                ]}
             ]}
          ]}
       ]}
    ]
  end
end
