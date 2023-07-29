defmodule Sleeky.Views.EntityDetail do
  @moduledoc false

  alias Sleeky.Entity
  alias Sleeky.Entity.Attribute
  alias Sleeky.Entity.Relation
  alias Sleeky.UI.View

  import Sleeky.Inspector
  import Sleeky.Views.Components

  def ast(ui, views, schema) do
    schema.entities() |> Enum.map(&detail_view(&1, ui, views))
  end

  defp detail_view(entity, _ui, views) do
    view = module_name(views, entity)
    attributes = attributes(entity, views)
    parents = parents(entity)
    actions = actions(entity)
    children = children(entity)

    definition =
      {:div, [scope(entity.plural()), mode(:show)],
       [
         [{:h1, [data(:name, :display)], []}] ++ parents ++ attributes ++ [actions, children]
       ]}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition, view))
      end
    end
  end

  def module_name(views, entity) do
    view = entity.label() |> module(Detail)
    module(views, view)
  end

  defp attributes(entity, _views) do
    entity.attributes
    |> Enum.reject(& &1.implied)
    |> Enum.reject(&(&1.name == :display))
    |> Enum.map(&attribute_view/1)
  end

  defp attribute_view(%Attribute{} = attr) do
    {:div, [],
     [
       label_view(attr.label),
       field_view(attr.name)
     ]}
  end

  defp parents(entity), do: Enum.map(entity.parents, &parent_view/1)

  defp parent_view(%Relation{} = rel) do
    target = rel.target.module

    {:div, [],
     [
       label_view(rel.label),
       link_view("/#{target.plural()}/$#{rel.name}.id", field_view("#{rel.name}.display"))
     ]}
  end

  defp children(entity) do
    relations = Enum.filter(entity.children, &Entity.action(:list, &1.target.module))

    children_switcher =
      {:div, [], Enum.map(relations, &link_view("/#{entity.plural}/$id/#{&1.name}", &1.label))}

    children_views = Enum.map(relations, &child_view(entity, &1))

    {:div, [], [children_switcher | children_views]}
  end

  defp child_view(entity, %Relation{} = child) do
    scope = entity.plural()
    child_entity = child.target.module

    {:div, [scope(child.name), mode(:children)],
     [
       {:h3, [], [child_entity.plural_label]},
       {:p, [], [link_view("/#{scope}/$id/#{child.name}/new", "Add new")]},
       {:ul, [],
        [
          {:template, [data(:each)],
           [
             {:li, [],
              [
                {:a, [data(:link, "/#{child_entity.plural}/$id")],
                 [
                   field_view(:display)
                 ]}
              ]}
           ]}
        ]}
     ]}
  end

  defp actions(entity) do
    scope = entity.plural

    {:div, [],
     [
       link_view("/#{scope}/$id/edit", "Edit"),
       link_view("/#{scope}/$id/delete", "Delete")
     ]}
  end
end
