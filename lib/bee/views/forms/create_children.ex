defmodule Bee.Views.Forms.CreateChildren do
  @moduledoc false

  alias Bee.Entity
  alias Bee.UI.View
  alias Bee.Views.Forms

  import Bee.Views.Components

  def action(_), do: true

  def ast(_ui, views, entity) do
    entity
    |> relations()
    |> Enum.map(&view(views, entity, &1))
  end

  def view(views, entity, relation) do
    view = module_name(views, entity, relation)
    target_entity = relation.target.module
    parents = Forms.Create.parent_fields(target_entity)
    attributes = Forms.Create.attribute_fields(target_entity, views)

    definition =
      {:div,
       [
         scope(entity.plural()),
         data("child-scope", target_entity.plural()),
         mode("newChild"),
         data("relation", relation.name),
         data(
           "inverse-relation",
           relation.inverse.name
         )
       ],
       [title_view("New #{target_entity.name()}")] ++
         parents ++ attributes ++ [button_view(:create)]}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition, view))
      end
    end
  end

  def module_name(views, entity, relation) do
    singular = Inflex.singularize(relation.name)
    intent = Inflex.camelize("create_#{singular}")
    Forms.module_name(views, entity, intent)
  end

  def relations(entity) do
    entity.children
    |> Enum.filter(fn rel ->
      Entity.action(:list, rel.target.module) &&
        Entity.action(:create, rel.target.module)
    end)
  end
end
