defmodule Bee.Views.Lists do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View

  def ast(ui, views, schema) do
    list_view = list_view(ui, views)

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

  def list_view(_ui, views) do
    module(views, Table)
  end

  def module_name(views, entity) do
    form = entity.label() |> module(List)
    module(views, form)
  end

  defp definition(_ui, entity, list_view) do
    {headers, fields} =
      entity.attributes
      |> Enum.reject(&(&1.name == :id))
      |> Enum.reduce({[], []}, fn attr, {labels, fields} ->
        {[[{:label, attr.label}] | labels],
         [[{:field, attr.name}, {:binding, "item.#{attr.name}"}] | fields]}
      end)

    {:div, ["x-show": "$store.default.should_display('#{entity.plural}', 'list')"],
     [
       {:view, list_view,
        [
          {:headers, [], headers},
          {:fields, [], fields},
          {:next_page, [], "$store.default.next_page()"},
          {:previous_page, [], "$store.default.previous_page()"},
          {:search, [], "$store.default.search"},
          {:update, [], "$store.default.list()"},
          {:select, [], "`#/#{entity.plural}/${item.id}`"}
        ]}
     ]}
  end
end
