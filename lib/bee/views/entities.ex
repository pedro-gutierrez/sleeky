defmodule Sleeki.Views.Entities do
  @moduledoc false

  alias Sleeki.Entity.Action
  alias Sleeki.UI.View
  alias Sleeki.Views.EntityDetail
  alias Sleeki.Views.Forms
  alias Sleeki.Views.Lists

  import Sleeki.Inspector

  def ast(_ui, views, schema) do
    view = module(views, Entities)
    definition = definition(views, schema)

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition, view))
      end
    end
  end

  defp definition(views, schema) do
    entity_views = schema.entities() |> Enum.map(&views(views, &1))

    {:div, [], entity_views}
  end

  defp views(views, entity) do
    views =
      entity.actions
      |> Enum.map(&view(&1, views, entity))
      |> flatten()
      |> Enum.map(&{:view, &1, []})

    {:entity, entity, views}
  end

  defp view(%Action{name: :create}, views, entity) do
    Forms.module_name(views, entity, :create)
  end

  defp view(%Action{name: :update}, views, entity) do
    Forms.module_name(views, entity, :update)
  end

  defp view(%Action{name: :list}, views, entity) do
    Lists.module_name(views, entity)
  end

  defp view(%Action{name: :read}, views, entity) do
    [EntityDetail.module_name(views, entity) | children_create_views(views, entity)]
  end

  defp view(%Action{name: :delete}, views, entity) do
    Forms.module_name(views, entity, :delete)
  end

  defp children_create_views(views, entity) do
    entity
    |> Forms.CreateChildren.relations()
    |> Enum.map(&Forms.CreateChildren.module_name(views, entity, &1))
  end
end
