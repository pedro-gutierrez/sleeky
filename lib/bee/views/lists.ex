defmodule Bee.Views.Lists do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    list_view = module(ui, List)

    for entity <- schema.entities() do
      module_name = module_name(views, entity)
      definition = definition(ui, entity, list_view)

      quote do
        defmodule unquote(module_name) do
          unquote(View.ast(definition))
        end
      end
    end
  end

  defp module_name(views, entity) do
    form = entity.label() |> module(List)
    module(views, form)
  end

  defp definition(_ui, entity, list_view) do
    {headers, bindings} =
      entity.attributes
      |> Enum.reject(&(&1.name == :id))
      |> Enum.reduce({[], []}, fn attr, {labels, fields} ->
        {[[{:label, attr.label}] | labels],
         [[{:field, attr.name}, {:binding, "#{entity.name}.#{attr.name}"}] | fields]}
      end)

    {:div, ["x-show": "$store.router.mode == 'list'"],
     [
       {:view, list_view,
        [
          {:headers, [], headers},
          {:fields, [], bindings},
          {:onclick, [], "$store.router.show('#{entity.plural}', #{entity.name}.id)"}
        ]}
     ]}
  end
end
