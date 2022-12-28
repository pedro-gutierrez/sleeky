defmodule Bee.UI.Client.Router do
  @moduledoc false

  alias ESTree.Tools.Builder, as: JS

  import Bee.UI.Client.Helpers

  def ast(_schema) do
    [
      store(),
      location_hash()
    ]
  end

  defp store do
    name = JS.literal(:router)

    store =
      JS.object_expression([
        path() |> JS.property(JS.array_expression([])),
        items() |> JS.property(null()),
        id() |> JS.property(null()),
        mode() |> JS.property(list_mode()),
        sync("show", [items(), id()], [
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
          assign(:path, JS.array_expression([]))
        ]),
        sync("push", [JS.identifier(:label)], [
          call("this.path.push", [
            JS.object_expression([
              JS.identifier(:label) |> JS.property(JS.identifier(:label)),
              JS.identifier(:id) |> JS.property(JS.identifier(:label))
            ])
          ])
        ]),
        sync("is_last", [JS.identifier(:label)], [])
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
