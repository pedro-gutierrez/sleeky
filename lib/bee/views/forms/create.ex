defmodule Bee.Views.Forms.Create do
  @moduledoc false

  alias Bee.Entity
  alias Bee.UI.View

  import Bee.Inspector
  import Bee.Views.Components

  def action(entity), do: Entity.action(:create, entity)

  def ast(_ui, views, entity) do
    form = module(entity.label(), "CreateForm")
    module_name = module(views, form)
    parents = parent_fields(entity)
    attributes = attribute_fields(entity)
    scope = entity.plural()

    definition =
      {:div, [scope(scope), mode(:new)],
       [title_view("New #{entity.name()}")] ++
         parents ++ attributes ++ [button_view(:create)]}

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end

  def attribute_fields(entity) do
    entity.attributes
    |> Enum.reject(& &1.virtual)
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.timestamp)
    |> Enum.reject(& &1.implied)
    |> Enum.map(&form_input_view(&1.label, :text, &1.name))
  end

  def parent_fields(entity) do
    entity.parents
    |> Enum.reject(& &1.computed)
    |> Enum.map(&pickup_view(&1.target.module.plural(), &1.name))
  end
end
