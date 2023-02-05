defmodule Bee.Views.EntityDetail do
  @moduledoc false

  import Bee.Inspector
  alias Bee.Entity
  alias Bee.Entity.Relation
  alias Bee.UI.View
  alias Bee.Views.EntityChildrenLists

  def ast(ui, views, schema) do
    schema.entities() |> Enum.map(&detail_view(&1, ui, views))
  end

  defp detail_view(entity, ui, views) do
    module_name = module_name(views, entity)
    attributes = attributes(entity, ui, views)
    parents = parents(entity)

    show = show(entity)
    data = data(entity)
    init = init(entity)

    main = entity_detail(entity, attributes, parents)

    side =
      {:div, [],
       [
         children_switcher(entity) | entity_children(entity, views)
       ]}

    definition =
      {:div, ["x-data": data, "x-show": show, "x-init": init],
       [
         {:h1, [class: "title"],
          [
            {:span, ["x-text": "item.display"], []}
          ]},
         {:div, [class: "columns"],
          [
            {:div, [class: "column"], main},
            {:div, [class: "column"], side}
          ]}
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

  defp attributes(entity, _ui, views) do
    entity.attributes
    |> Enum.reject(& &1.implied)
    |> Enum.reject(&(&1.name == :display))
    |> Enum.map(fn attr ->
      {:view, module(views, Label),
       [
         {:label, attr.label},
         {:model, "item.#{attr.name}"}
       ]}
    end)
  end

  defp entity_detail(entity, attributes, parents) do
    [
      {:div, [class: "box is-shadowless"], parents ++ attributes},
      {:div, [],
       [
         action_link(entity, "edit", "Edit this #{String.downcase(entity.label)}"),
         action_link(entity, "delete", "Delete")
       ]}
    ]
  end

  defp action_link(entity, action, label) do
    {:a,
     [
       "x-bind:href": "`/#/#{entity.plural}/${item.id}/#{action}`",
       class: "is-size-6 has-text-weight-normal	has-text-primary ml-0 mr-2"
     ], [label]}
  end

  defp parents(entity), do: Enum.map(entity.parents, &parent_link/1)

  defp parent_link(%Relation{} = rel) do
    target = rel.target.module

    {:div, [class: "field"],
     [
       {:label, [class: "label"], ["#{rel.label}"]},
       {:div, [class: "control"],
        [
          {:a,
           [
             "x-bind:href": "`/#/#{target.plural()}/${item.#{rel.name}?.id}`",
             "x-text": "item.#{rel.name}?.display",
             class: "has-text-primary"
           ], []}
        ]}
     ]}
  end

  defp listable_children(entity) do
    Enum.filter(entity.children, &list_children?(&1))
  end

  defp entity_children(entity, views) do
    entity
    |> listable_children()
    |> Enum.map(&children_view(views, entity, &1))
  end

  defp children_view(views, entity, rel) do
    {:view, EntityChildrenLists.module_name(views, entity, rel)}
  end

  defp children_switcher(entity) do
    buttons =
      entity
      |> listable_children()
      |> Enum.map(&children_button/1)

    {:div, [], buttons}
  end

  defp children_button(rel) do
    entity = rel.entity
    target = rel.target

    {:a,
     [
       class: "button border-bottom-radius-0",
       "x-bind:href": "`#/#{entity.plural}/${item.id}/#{target.plural}`",
       "x-bind:class": "children == '#{target.plural}' ? 'is-white' : 'is-ghost has-text-primary'"
     ], [rel.target.plural]}
  end

  defp list_children?(rel), do: Entity.action(:list, rel.target.module)

  defp init(entity) do
    """
    $watch('$store.$.state', async (s) => {
      if (#{show(entity)}) {
        ({item, messages} = await read_item('#{entity.plural}', s.id));
        if (s.children) children = s.children
      }
    });
    """
  end

  defp show(entity) do
    "$store.$.should_display('#{entity.plural()}', 'show')"
  end

  def data(entity) do
    default_children =
      case entity |> listable_children() |> List.first() do
        nil -> "null"
        rel -> "'#{rel.target.plural}'"
      end

    "{ messages: [], item: {}, children: #{default_children} }"
  end
end
