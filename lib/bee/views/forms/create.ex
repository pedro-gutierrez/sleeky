defmodule Bee.Views.Forms.Create do
  @moduledoc false

  alias Bee.Entity
  alias Bee.UI.View

  import Bee.Inspector
  import Bee.Views.Forms.Helpers

  def action(entity), do: Entity.action(:create, entity)

  def ast(ui, views, entity) do
    form = module(entity.label(), "CreateForm")
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

  def data(_entity) do
    "{ messages: [], item: {} }"
  end

  defp show(entity) do
    "$store.default.should_display('#{entity.plural()}', 'create')"
  end

  defp buttons(entity, _ui, _views) do
    [
      button(
        "Create #{entity.name()}",
        "({item, messages} = await create('#{entity.plural()}', #{payload(entity)})); if (!messages.length) {
        id = item.id; item = {}; visit(`/#/#{entity.plural()}/${id}`) }"
      )
    ]
  end

  defp fields(entity, ui, views) do
    parent_fields(entity, ui, views) ++
      attribute_fields(entity, ui, views)
  end

  defp attribute_fields(entity, ui, views) do
    entity
    |> attributes()
    |> Enum.map(&field(ui, views, &1))
  end

  defp parent_fields(entity, ui, views) do
    entity
    |> parents()
    |> Enum.map(&field(ui, views, &1))
  end

  defp attributes(entity) do
    entity.attributes
    |> Enum.reject(& &1.virtual)
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.timestamp)
    |> Enum.reject(& &1.implied)
  end

  defp parents(entity) do
    Enum.reject(entity.parents, & &1.computed)
  end

  defp payload(entity) do
    attributes =
      entity
      |> attributes()
      |> Enum.map_join(",", &"#{&1.name}: item.#{&1.name}")

    parents =
      entity
      |> parents()
      |> Enum.map_join(",", &"#{&1.name}: item.#{&1.name}?.id")

    "{ #{attributes}, #{parents} }"
  end
end
