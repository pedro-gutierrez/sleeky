defmodule Bee.Views.Select do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    view = module(views, Select)
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
          {:select,
           [
             class: "select is-light",
             "x-model": {:slot, :model},
             placeholder: {:slot, :placeholder}
           ], []}
        ]}
     ]}
  end
end
