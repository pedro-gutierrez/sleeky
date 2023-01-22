defmodule Bee.Views.EntityDetail do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View
  alias Bee.Entity.Attribute
  alias Bee.Entity.Relation

  def ast(ui, views, schema) do
    schema.entities() |> Enum.map(&detail_view(&1, ui, views))
  end

  defp detail_view(entity, ui, views) do
    module_name = module_name(views, entity)
    detail_view = module(views, Detail)
    actions_view = module(views, Actions)
    children_view = module(views, Children)
    parents_view = module(views, Parents)
    fields = fields(entity, ui, views)

    show = show(entity)
    data = data(entity)
    init = init(entity)

    main = entity_detail(entity, detail_view, fields)

    side =
      flatten([
        entity_actions(entity, actions_view),
        entity_parents(entity, parents_view),
        entity_children(entity, children_view)
      ])

    definition =
      {:div, [class: "columns", "x-data": data, "x-show": show, "x-init": init],
       [
         {:div, [class: "column"], main},
         {:div, [class: "column"], side}
       ]}

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end

  def module_name(views, entity) do
    view = entity.label() |> module(Detail)
    module(views, view)
  end

  defp label_view(_ui, views) do
    module(views, Label)
  end

  defp fields(entity, ui, views) do
    entity.attributes
    |> Enum.reject(& &1.implied)
    |> Enum.map(&label(ui, views, &1))
  end

  defp entity_detail(_entity, detail_view, fields) do
    {:view, detail_view,
     [
       {:fields, [], flatten(fields)}
     ]}
  end

  defp entity_actions(entity, actions_view) do
    {:view, actions_view,
     [
       {:items, [],
        [
          [label: "Edit this #{entity.name()}", url: item_url(entity, "edit")],
          [label: "Delete this #{entity.name()}", url: item_url(entity, "delete")]
        ]}
     ]}
  end

  defp entity_parents(entity, parents_view) do
    if Enum.empty?(entity.parents) do
      nil
    else
      parents = Enum.map(entity.parents, &parent_link/1)

      {:view, parents_view,
       [
         {:items, [], parents}
       ]}
    end
  end

  defp entity_children(entity, children_view) do
    if Enum.empty?(entity.children) do
      nil
    else
      children = Enum.map(entity.children, &child_link/1)
      data = "{ messages: [], #{entity.children |> Enum.map(&child_data/1) |> Enum.join(", ")}}"

      init =
        "$watch('item', async (v) => { if (#{show(entity)}) { #{entity.children |> Enum.map(&child_count/1) |> Enum.join(" ")} }})"

      {:view, children_view,
       [
         {:data, [], data},
         {:init, [], init},
         {:items, [], children}
       ]}
    end
  end

  defp child_link(%Relation{name: name, entity: entity}) do
    select = item_url(entity, name)
    label = "`${#{name}} #{name}`"

    [
      {:label, label},
      {:url, select}
    ]
  end

  defp child_data(%Relation{name: name}) do
    "#{name}: 0"
  end

  defp child_count(%Relation{name: name, entity: entity}) do
    "let #{name}_aggregate = await aggregate_children('#{entity.plural()}', v, '#{name}'); #{name} =
    #{name}_aggregate.count;"
  end

  defp parent_link(%Relation{} = rel) do
    [
      {:label, "Show #{rel.name}"},
      {:url, parent_url(rel)}
    ]
  end

  defp item_url(entity, name) do
    "`/#/#{entity.plural()}/${item.id}/#{name}`"
  end

  defp parent_url(rel) do
    target = rel.target.module

    "`/#/#{target.plural()}/${item.#{rel.name}?.id}`"
  end

  defp label(ui, views, %Attribute{} = attr) do
    field_view = label_view(ui, views)

    {:view, field_view,
     [
       {:label, attr.label},
       {:model, "item.#{attr.name}"}
     ]}
  end

  defp init(entity) do
    "$watch('$store.default.item', (v) => { if (#{show(entity)}) item = v })"
  end

  defp show(entity) do
    "$store.default.should_display('#{entity.plural()}', 'show')"
  end

  def data(_entity) do
    "{ messages: [], item: {} }"
  end
end
