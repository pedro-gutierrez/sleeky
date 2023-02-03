defmodule Bee.Views.Entities do
  @moduledoc false

  alias Bee.Entity.Action
  alias Bee.UI.View
  alias Bee.Views.EntityDetail
  alias Bee.Views.Forms
  alias Bee.Views.Lists

  import Bee.Inspector

  def ast(_ui, views, schema) do
    module_name = module(views, Entities)
    definition = definition(views, schema)

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
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
    list_view = Lists.module_name(views, entity)

    list_view
  end

  defp view(%Action{name: :read}, views, entity) do
    EntityDetail.module_name(views, entity)
  end

  defp view(%Action{name: :delete}, views, entity) do
    Forms.module_name(views, entity, :delete)
  end
end
