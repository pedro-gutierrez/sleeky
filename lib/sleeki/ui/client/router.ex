defmodule Sleeki.UI.Client.Router do
  @moduledoc false

  alias ESTree.Tools.Builder, as: JS

  import Sleeki.UI.Client.Helpers

  def ast(_schema) do
    [
      data(),
      store(),
      location_hash(),
      effect()
    ]
  end

  def data do
    JS.variable_declaration([
      JS.variable_declarator(
        JS.identifier(:data),
        call("Alpine.reactive", [
          JS.object_expression([
            JS.identifier(:location) |> JS.property(JS.array_expression([]))
          ])
        ])
      )
    ])
  end

  def effect do
    call("Alpine.effect", [
      arrow_function([], [
        assign(
          "window.location.hash",
          JS.binary_expression(
            JS.identifier("+"),
            JS.literal("/"),
            "data.location"
            |> JS.identifier()
            |> call("map", [
              arrow_function([JS.identifier(:p)], [
                JS.return_statement(
                  JS.member_expression(JS.identifier(:p), JS.identifier(:label))
                )
              ])
            ])
            |> call("join", [JS.literal("/")])
          )
        )
      ])
    ])
  end

  defp store do
    name = JS.literal(:router)

    store =
      JS.object_expression([
        :data |> JS.identifier() |> JS.property(JS.identifier(:data)),
        items() |> JS.property(null()),
        id() |> JS.property(null()),
        mode() |> JS.property(list_mode()),
        sync("show", [items(), id()], [
          call("console.log", [
            JS.literal("showing"),
            JS.array_expression([
              items(),
              id()
            ])
          ]),
          assign(:items),
          assign(:id),
          JS.if_statement(
            id(),
            JS.block_statement([
              assign(:mode, "update"),
              call("this.reset", []),
              call("this.push", [JS.identifier(:items)]),
              call("this.push", [JS.identifier(:id)])
            ]),
            JS.block_statement([
              assign(:mode, "list"),
              call("this.reset", []),
              call("this.push", [JS.identifier(:items)])
            ])
          )
        ]),
        sync("create", [], [
          assign(:mode, "create")
        ]),
        sync("reset", [], [
          call("Alpine.nextTick", [
            arrow_function([], [
              assign(
                "data.location",
                JS.array_expression([])
              )
            ])
          ])
        ]),
        sync("push", [JS.identifier(:label)], [
          call("Alpine.nextTick", [
            arrow_function([], [
              call("data.location.push", [
                JS.object_expression([
                  JS.identifier(:label) |> JS.property(JS.identifier(:label)),
                  JS.identifier(:id) |> JS.property(JS.identifier(:label))
                ])
              ])
            ])
          ])
        ])
      ])

    call("Alpine.store", [name, store])
  end

  defp location_hash do
    path =
      JS.variable_declaration([
        JS.variable_declarator(
          JS.identifier(:path),
          call("location.hash.split", [JS.literal("/")])
        )
      ])

    show_page =
      "Alpine.store"
      |> call([JS.literal("router")])
      |> call(:show, [JS.identifier("path[1] || ''"), JS.identifier("path[2]")])

    [
      path,
      show_page
    ]
  end
end
