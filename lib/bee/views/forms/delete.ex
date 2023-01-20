defmodule Bee.Views.Forms.Delete do
  @moduledoc false

  alias Bee.Entity
  alias Bee.UI.View

  import Bee.Inspector

  def action(entity), do: Entity.action(:delete, entity)

  def ast(_ui, views, entity) do
    form = module(entity.label(), "DeleteForm")
    module_name = module(views, form)
    show = "$store.default.should_display('#{entity.plural()}', 'delete')"

    definition =
      {:div,
       [
         class: "box hero is-shadowless has-background-danger-light",
         "x-show": show
       ],
       [
         {:div, [class: "container"],
          [
            {:p, [class: "block has-text-danger"], ["Are you sure you want to delete this?"]},
            {:div, [class: "field is-grouped is-grouped-centered"],
             [
               {:div, [class: "control"],
                [
                  {:a,
                   [
                     href: "#",
                     class: "button is-danger",
                     "x-on:click": "$store.default.delete()"
                   ],
                   [
                     "Delete"
                   ]}
                ]}
             ]}
          ]}
       ]}

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end
end
