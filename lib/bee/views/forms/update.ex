defmodule Bee.Views.Forms.Update do
  @moduledoc false

  alias Bee.Entity
  alias Bee.UI.View

  import Bee.Inspector
  import Bee.Views.Forms.Helpers

  def action(entity), do: Entity.action(:create, entity)

  def ast(ui, views, entity) do
    form = module(entity.label(), "UpdateForm")
    module_name = module(views, form)
    show = show(entity)
    data = data(entity)
    fields = fields(entity, ui, views)
    buttons = buttons(entity, ui, views)
    messages = messages(ui, views)
    definition = definition(show, data, messages, fields, buttons)

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end

  defp show(entity) do
    "$store.default.should_display('#{entity.plural()}', 'update')"
  end

  def data(_entity) do
    "{ messages: [], item: {} }"
  end

  defp buttons(entity, _ui, _views) do
    [button("Update #{entity.name()}", "")]
  end

  defp fields(entity, ui, views) do
    parent_fields(entity, ui, views) ++
      attribute_fields(entity, ui, views)
  end

  defp attribute_fields(entity, ui, views) do
    entity.attributes
    |> Enum.reject(& &1.immutable)
    |> Enum.reject(& &1.virtual)
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.timestamp)
    |> Enum.reject(& &1.implied)
    |> Enum.map(&field(ui, views, &1))
  end

  defp parent_fields(entity, ui, views) do
    entity.parents
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.computed)
    |> Enum.map(&field(ui, views, &1))
  end
end
