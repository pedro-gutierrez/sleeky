defmodule Bee.Views.Input do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = module(views, Input)
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
       {:label, [class: "label"], [{:slot, :label}]},
       {:div, [class: "control"],
        [
          {:input,
           [
             type: {:slot, :kind},
             class: "input is-light",
             "x-model": "item.{{ name }}",
             placeholder: "Enter {{ name }}"
           ], []}
        ]}
     ]}
  end
end
