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
       {:slot, :fields}
     ]}
  end
end
