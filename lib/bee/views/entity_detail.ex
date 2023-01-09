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
    detail_view = detail_view(ui, views)
    children_view = children_view(ui, views)
    fields = fields(entity, ui, views)

    show = ["x-show": "$store.default.should_display('#{entity.plural()}', 'show')"]

    definition =
      if has_related_entities?(entity) do
        {:div, Keyword.merge(show, class: "columns"),
         [
           {:div, [class: "column"], entity_detail(entity, detail_view, fields)},
           {:div, [class: "column"],
            flatten([
              entity_parents(entity),
              entity_children(entity, children_view)
            ])}
         ]}
      else
        entity_detail(entity, detail_view, fields, show)
      end

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

  defp has_related_entities?(entity) do
    Enum.count(entity.parents) +
      Enum.count(entity.children) > 0
  end

  defp detail_view(_ui, views) do
    module(views, Detail)
  end

  defp children_view(_ui, views) do
    module(views, Children)
  end

  defp label_view(_ui, views) do
    module(views, Label)
  end

  defp fields(entity, ui, views) do
    entity.attributes
    |> Enum.reject(& &1.implied)
    |> Enum.map(&label(ui, views, &1))
  end

  defp entity_detail(entity, detail_view, fields, attrs \\ []) do
    {:div, attrs,
     [
       {:view, detail_view,
        [
          {:fields, [], flatten(fields)},
          {:edit, [], item_url(entity, "edit")},
          {:delete, [], item_url(entity, "delete")},
          {:cancel, [], "`/#/#{entity.plural()}`"}
        ]}
     ]}
  end

  defp entity_parents(entity) do
    if Enum.empty?(entity.parents) do
      nil
    else
    end
  end

  defp entity_children(entity, children_view) do
    if Enum.empty?(entity.children) do
      nil
    else
      children = Enum.map(entity.children, &child_link/1)

      {:view, children_view,
       [
         {:items, [], children}
       ]}
    end
  end

  defp child_link(%Relation{name: name, entity: entity}) do
    select = item_url(entity, name)
    count = "$store.default.children.#{name}"

    [
      {:label, name},
      {:url, select},
      {:count, count}
    ]
  end

  defp item_url(entity, name) do
    "`/#/#{entity.plural()}/${$store.default.item.id}/#{name}`"
  end

  defp label(ui, views, %Attribute{} = attr) do
    field_view = label_view(ui, views)

    {:view, field_view,
     [
       {:label, attr.label},
       {:model, "$store.default.item.#{attr.name}"},
       {:name, attr.name}
     ]}
  end
end
