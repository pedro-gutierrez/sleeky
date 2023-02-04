defmodule Bee.Views.Forms.Delete do
  @moduledoc false

  alias Bee.Entity
  alias Bee.UI.View

  import Bee.Inspector

  def action(entity), do: Entity.action(:delete, entity)

  def ast(_ui, views, entity) do
    form = module(entity.label(), "DeleteForm")
    module_name = module(views, form)
    show = show(entity)
    data = data(entity)
    init = init(entity)
    buttons = buttons(entity)

    definition =
      {:div,
       [
         class: "box hero is-shadowless has-background-danger-light",
         "x-show": show,
         "x-data": data,
         "x-init": init
       ],
       [
         {:div, [class: "container"],
          [
            {:p, [class: "block has-text-danger"], ["Are you sure you want to delete this?"]},
            {:div, [class: "field is-grouped is-grouped-centered"], buttons}
          ]}
       ]}

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end

  defp show(entity) do
    "$store.default.should_display('#{entity.plural()}', 'delete')"
  end

  defp init(entity) do
    """
    $watch('$store.default.path', async (v) => {
      if (#{show(entity)}) {
        ({item, messages} = await read_item('#{entity.plural()}', $store.default.id))
      }
    })
    """
  end

  def data(_entity) do
    "{ messages: [], item: {} }"
  end

  defp buttons(entity) do
    [
      button(
        "Delete #{entity.name()}",
        "({item, messages} = await delete_item('#{entity.plural()}', item));
      if (!messages.length) { visit('/#/#{entity.plural()}') }"
      )
    ]
  end

  defp button(title, click) do
    {:div, [class: "control"],
     [
       {:a,
        [
          class: "button is-danger",
          "x-on:click": click
        ],
        [
          title
        ]}
     ]}
  end
end
