defmodule Bee.Views.EntityChildrenLists do
  @moduledoc false

  import Bee.Inspector
  alias Bee.Entity.Relation
  alias Bee.UI.View

  def ast(ui, views, schema) do
    list_view = list_view(ui, views)

    for entity <- schema.entities(), rel <- entity.children() do
      target = rel.target.module
      Code.ensure_compiled!(target)

      module_name = module_name(views, entity, rel)
      definition = definition(ui, entity, rel, target, list_view)

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

  def module_name(views, entity, %Relation{kind: :child} = rel) do
    name = module([entity.label(), rel.label, List])
    module(views, name)
  end

  defp definition(_ui, entity, rel, target, list_view) do
    {headers, fields} =
      target.attributes
      |> Enum.reject(&(&1.name == :id))
      |> Enum.reduce({[], []}, fn attr, {labels, fields} ->
        {[[{:label, attr.label}] | labels],
         [[{:field, attr.name}, {:binding, "i.#{attr.name}"}] | fields]}
      end)

    show = show(entity)
    data = data(entity)
    init = init(entity, rel)

    {:div, ["x-show": show, "x-data": data, "x-init": init],
     [
       {:view, list_view,
        [
          {:headers, [], headers},
          {:fields, [], fields},
          {:next_page, [], "page = page + 1; #{search(entity, rel)}"},
          {:previous_page, [], "page = page = 1; #{search(entity, rel)}"},
          {:search, [], "query"},
          {:update, [], search(entity, rel)},
          {:select, [], "`#/#{target.plural}/${i.id}`"}
        ]}
     ]}
  end

  defp show(entity) do
    "$store.default.should_display('#{entity.plural}', 'show')"
  end

  defp data(_entity) do
    "{ messages: [], items: [], query: '', page: 1, page_size: 10 }"
  end

  defp init(entity, rel) do
    "$watch('item', async (v) => { if (#{show(entity)}) { #{search(entity, rel)} }})"
  end

  defp search(entity, rel) do
    "({items, messages} = await search_children('#{entity.plural()}', item, '#{rel.name}', {query, page, page_size}))"
  end
end
