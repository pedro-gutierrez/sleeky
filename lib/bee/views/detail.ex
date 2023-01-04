defmodule Bee.Views.Detail do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = module(views, Detail)
    definition = definition(ui, schema)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition))
      end
    end
  end

  defp definition(_ui, _schema) do
    {:div, [class: "box is-shadowless"],
     [
       {:slot, :fields},
       {:div, [class: "field is-grouped"],
        [
          {:p, [class: "control"],
           [
             {:a, ["x-bind:href": {:slot, :edit}, class: "button is-primary"],
              [
                "Edit"
              ]}
           ]},
          {:p, [class: "control"],
           [
             {:a, ["x-bind:href": {:slot, :delete}, class: "button is-danger"],
              [
                "Delete"
              ]}
           ]},
          {:p, [class: "control"],
           [
             {:a, ["x-bind:href": {:slot, :cancel}, class: "button is-light"],
              [
                "Cancel"
              ]}
           ]}
        ]}
     ]}
  end
end
