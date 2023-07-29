defmodule Sleeky.Views.Forms.Create do
  @moduledoc false

  alias Sleeky.Entity
  alias Sleeky.UI.View
  alias Sleeky.Views

  import Sleeky.Inspector

  def action(entity), do: Entity.action(:create, entity)

  def ast(_ui, views, entity) do
    form = module(entity.label(), "CreateForm")
    view = module(views, form)
    parents = parent_fields(entity, views)
    attributes = attribute_fields(entity, views)
    scope = entity.plural()
    title = "New #{entity.name()}"

    definition =
      {:div, [{"data-scope", scope}, {"data-mode", "new"}],
       [title_view(views, title)] ++
         parents ++
         attributes ++
         [submit_view(views, :create, "Submit")]}

    quote do
      defmodule unquote(view) do
        unquote(View.ast(definition, view))
      end
    end
  end

  def attribute_fields(entity, views) do
    entity.attributes
    |> Enum.reject(& &1.virtual)
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.timestamp)
    |> Enum.reject(& &1.implied)
    |> Enum.map(&attribute_view(&1, views))
  end

  def attribute_view(attr, views) do
    {:view, module(views, TextInput), label: attr.label, name: attr.name}
  end

  def parent_fields(entity, views) do
    entity.parents
    |> Enum.reject(& &1.computed)
    |> Enum.map(&Views.pickup_view(&1, views))
  end

  defp title_view(views, title) do
    title_view = module(views, Title)
    {:view, title_view, [title: title]}
  end

  defp submit_view(views, action, label) do
    button_view = module(views, Button)
    {:view, button_view, [label: label, action: action]}
  end
end
