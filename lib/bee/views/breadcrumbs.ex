defmodule Bee.Views.Breadcrumbs do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = module(views, Breadcrumbs)
    definition = definition(ui, schema)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end

  defp definition(_ui, _schema) do
    {:nav, [class: "breadcrumb has-arrow-separator"],
     [
       {:ul, [],
        [
          {:loop, [:path],
           [
             {:li, [],
              [
                {:a,
                 [
                   "x-bind:href": "item.location",
                   class: "has-text-primary"
                 ],
                 [
                   {:span, ["x-text": "item.label"], []}
                 ]}
              ]}
           ]}
        ]}
     ]}
  end
end
