defmodule Sleeky.Ui.Generator.NewViews do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(ui, _opts) do
    for context <- ui.contexts, model <- context.models(), %{name: :create} <- model.actions() do
      module_name = Module.concat(model, UiNewView)
      action = Enum.join([context.name(), model.plural(), "new"], "/")
      action = "/" <> action

      quote do
        defmodule unquote(module_name) do
          use Sleeky.View

          view do
            form action: unquote(action), method: :post do
              button do
                "Save"
              end
            end
          end
        end
      end
    end
  end
end
