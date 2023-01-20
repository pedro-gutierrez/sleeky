defmodule Bee.Views.Textarea do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = module(views, Textarea)
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
       {:label, [class: "label"], [{:slot, :name}]},
       {:div, [class: "control"],
        [
          {:textarea,
           [
             class: "textarea is-light",
             "x-model": "item.{{ name }}",
             placeholder: "Enter {{ name }}"
           ], []}
        ]}
     ]}
  end
end
