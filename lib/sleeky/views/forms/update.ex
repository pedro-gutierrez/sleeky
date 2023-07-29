defmodule Sleeky.Views.Forms.Update do
  @moduledoc false

  alias Sleeky.Entity
  alias Sleeky.UI.View
  alias Sleeky.Views

  import Sleeky.Inspector
  import Sleeky.Views.Components

  def action(entity), do: Entity.action(:create, entity)

  def ast(_ui, views, entity) do
    form = module(entity.label(), "UpdateForm")
    view = module(views, form)
    parents = parent_fields(entity, views)
    attributes = attribute_fields(entity)
    scope = entity.plural()

    definition =
      {:div, [scope(scope), mode(:edit)],
       [{:h1, [data(:name, :display)], []}] ++
         parents ++ attributes ++ [button_view(:edit)]}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition, view))
      end
    end
  end

  defp attribute_fields(entity) do
    entity.attributes
    |> Enum.reject(& &1.virtual)
    |> Enum.reject(& &1.immutable)
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.timestamp)
    |> Enum.reject(& &1.implied)
    |> Enum.map(&form_input_view(&1.label, :text, &1.name))
  end

  defp parent_fields(entity, views) do
    entity.parents
    |> Enum.reject(& &1.computed)
    |> Enum.map(&Views.pickup_view(&1, views))
  end
end
