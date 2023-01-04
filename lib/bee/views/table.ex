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
               class: "input is-light is-inline mr-1",
               placeholder: "Search"
             ], []},
            {:a,
             [
               class: "button mx-1 is-light",
               title: "Previous page",
               "x-on:click": {:slot, :previous_page}
             ],
             [
               {:span, [class: "icon"],
                [
                  {:i, [class: "fa-solid fa-arrow-left"], []}
                ]}
             ]},
            {:a,
             [
               class: "button mx-1 is-light",
               title: "Next page",
               "x-on:click": {:slot, :next_page}
             ],
             [
               {:span, [class: "icon"],
                [
                  {:i, [class: "fa-solid fa-arrow-right"], []}
                ]}
             ]},
            {:a,
             [
               class: "button mx-1 is-primary is-pulled-right",
               "x-bind:href": "`#/${$store.router.entity}/new`"
             ],
             [
               {:span, [class: "icon"],
                [
                  {:i, [class: "fa fa-plus"], []}
                ]},
               {:span, [], "Create new"}
             ]}
          ]},
         {:table, [class: "table is-fullwidth is-borderless is-hoverable mt-4"],
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
               {:loop, [],
                [
                  {:tr, [],
                   [
                     {:slot, :fields,
                      [
                        {:td, ["x-text": {:slot, :binding}], []}
                      ]},
                     {:td, [],
                      [
                        {:a,
                         [
                           "x-bind:href": {:slot, :select},
                           class: "is-pulled-right has-text-primary"
                         ],
                         [
                           {:i, [class: "fa-solid fa-arrow-right"], []}
                         ]}
                      ]}
                   ]}
                ]}
             ]}
          ]}
       ]}
    ]
  end
end
