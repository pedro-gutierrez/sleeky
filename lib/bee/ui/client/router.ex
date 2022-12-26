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
        items() |> JS.property(null()),
        id() |> JS.property(null()),
        mode() |> JS.property(list_mode()),
        sync("show", [items(), id()], [
          assign(:items),
          assign(:id),
          JS.if_statement(id(), assign(:mode, "update"), assign(:mode, "list"))
        ]),
        sync("create", [], [
          assign(:mode, "create")
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
