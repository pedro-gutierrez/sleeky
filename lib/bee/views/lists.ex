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
         [[{:field, attr.name}, {:binding, "i.#{attr.name}"}] | fields]}
      end)

    show = show(entity)
    data = data(entity)
    init = init(entity)

    {:div, ["x-show": show, "x-data": data, "x-init": init],
     [
       {:view, list_view,
        [
          {:class, [], ""},
          {:headers, [], headers},
          {:fields, [], fields},
          {:search, [], "query"},
          {:update, [], search(entity)},
          {:create, [], "#/#{entity.plural}/new"},
          {:select, [], "#/#{entity.plural}/${i.id}"}
        ]}
     ]}
  end

  defp show(entity) do
    "$store.default.should_display('#{entity.plural}', 'list')"
  end

  defp data(_entity) do
    "{ messages: [], items: [], query: '', page: 1, page_size: 25 }"
  end

  defp init(entity) do
    "$watch('$store.default.path', async (v) => { if (#{show(entity)}) { #{search(entity)} }})"
  end

  defp search(entity) do
    "({items, messages} = await search_items('#{entity.plural()}', {query, page, page_size}))"
  end
end
