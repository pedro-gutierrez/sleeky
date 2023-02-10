defmodule Bee.Views.Breadcrumbs do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(_ui, views, _schema) do
    view = module(views, Breadcrumbs)

    data = data()
    init = init()
    definition = definition(data, init)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end

  defp data do
    "{ path: [] }"
  end

  defp init do
    """
    $watch('$store.$.state', (v) => {
      path = [];
      if (v.collection) path.push({ id: v.collection, uri: `/#/${v.collection}` })
      if (v.id) path.push({id: v.id, uri: `/#/${v.collection}/${v.id}` })
      if (v.mode === 'edit' || v.mode === 'new'  || v.mode === 'delete' ) path.push({ id: v.mode,  uri:
    `/#/${v.collection}/${v.id}/${v.mode}` })
      if (v.children) path.push({id: v.children, uri: `/#/${v.collection}/${v.id}/${v.children}` })
    })
    """
  end

  defp definition(data, init) do
    {:nav, ["x-data": data, "x-init": init, class: "block"],
     [
       {:ul, [],
        [
          {:each, "path",
           [
             {:li, [class: "is-inline mr-2"],
              [
                {:a,
                 [
                   "x-bind:href": "i.uri",
                   class: "tag is-medium is-primary is-light"
                 ],
                 [
                   {:span, ["x-text": "i.id"], []}
                 ]}
              ]}
           ]}
        ]}
     ]}
  end
end
