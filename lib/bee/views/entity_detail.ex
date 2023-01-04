defmodule Bee.Views.EntityDetail do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View
  alias Bee.Entity.Attribute

  def ast(ui, views, schema) do
    schema.entities() |> Enum.map(&detail_view(&1, ui, views))
  end

  defp detail_view(entity, ui, views) do
    module_name = module_name(views, entity)
    detail_view = detail_view(ui, views)
    fields = fields(entity, ui, views)
    definition = definition(entity, detail_view, fields)

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

  defp detail_view(_ui, views) do
    module(views, Detail)
  end

  defp label_view(_ui, views) do
    module(views, Label)
  end

  defp fields(entity, ui, views) do
    entity.attributes
    |> Enum.reject(& &1.implied)
    |> Enum.map(&label(ui, views, &1))
  end

  def definition(entity, detail_view, fields) do
    {:div, ["x-show": "$store.router.should_display('#{entity.plural()}', 'show')"],
     [
       {:view, detail_view,
        [
          {:fields, [], flatten(fields)},
          {:edit, [], "`/#/#{entity.plural()}/${$store.#{entity.plural()}.item.id}/edit`"},
          {:delete, [], "`/#/#{entity.plural()}/${$store.#{entity.plural()}.item.id}/delete`"},
          {:cancel, [], "`/#/#{entity.plural()}`"}
        ]}
     ]}
  end

  defp label(ui, views, %Attribute{} = attr) do
    field_view = label_view(ui, views)
    model = model(attr)

    {:view, field_view,
     [
       {:label, attr.label},
       {:model, model},
       {:name, attr.name}
     ]}
  end

  defp model(%Attribute{entity: entity, name: name}) do
    store = entity.plural()

    "$store.#{store}.item.#{name}"
  end
end
