defmodule Bee.Views.Forms do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View
  alias Bee.Entity.Attribute

  def ast(ui, views, schema) do
    form_view = form_view(ui, views)

    for entity <- schema.entities() do
      [
        form(entity, :create, ui, views, form_view),
        form(entity, :update, ui, views, form_view),
        form(entity, :delete, ui, views, form_view)
      ]
    end
  end

  defp form_view(_ui, views) do
    module(views, Form)
  end

  defp form(entity, intent, ui, views, form_view) do
    module_name = module_name(views, entity, intent)
    fields = form_fields(entity, intent, ui, views)
    title = title(entity, intent)
    subtitle = subtitle(entity, intent)
    action = action(entity, intent)
    cancel = cancel(entity, intent)
    definition = definition(entity, form_view, title, subtitle, fields, action, cancel, intent)

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end

  def module_name(views, entity, intent) do
    intent = Inflex.camelize(intent)
    form = entity.label() |> module("#{intent}Form")
    module(views, form)
  end

  defp form_fields(_entity, :delete, _ui, _views) do
    []
  end

  defp form_fields(entity, _, ui, views) do
    entity.attributes
    |> Enum.reject(& &1.immutable)
    |> Enum.reject(& &1.virtual)
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.timestamp)
    |> Enum.reject(& &1.implied)
    |> Enum.map(&form_field(ui, views, &1))
  end

  def definition(entity, name, title, subtitle, fields, submit, cancel, intent) do
    {:div, ["x-show": "$store.router.should_display('#{entity.plural}', '#{intent}')"],
     [
       {:view, name,
        [
          {:title, [], title},
          {:subtitle, [], subtitle},
          {:fields, [], flatten(fields)},
          {:submit, [], submit},
          {:cancel, [], cancel}
        ]}
     ]}
  end

  defp input_view(_ui, views) do
    module(views, Input)
  end

  defp textarea_view(_ui, views) do
    module(views, Textarea)
  end

  defp select_view(_ui, views) do
    module(views, Select)
  end

  defp form_field(ui, views, %Attribute{kind: :string} = attr) do
    field_view = input_view(ui, views)
    model = model(attr)

    {:view, field_view,
     [
       {:label, attr.label},
       {:name, attr.name},
       {:kind, "text"},
       {:model, model},
       {:placeholder, "Enter #{attr.name}"}
     ]}
  end

  defp form_field(ui, views, %Attribute{kind: :text} = attr) do
    field_view = textarea_view(ui, views)
    model = model(attr)

    {:view, field_view,
     [
       {:label, attr.label},
       {:name, attr.name},
       {:model, model},
       {:placeholder, "Enter #{attr.name}"}
     ]}
  end

  defp form_field(ui, views, %Attribute{kind: :enum} = attr) do
    field_view = select_view(ui, views)
    model = model(attr)

    {:view, field_view,
     [
       {:label, attr.label},
       {:name, attr.name},
       {:model, model},
       {:placeholder, "Enter #{attr.name}"}
     ]}
  end

  defp model(attr) do
    store = attr.entity.plural
    name = attr.name

    "$store.#{store}.item.#{name}"
  end

  defp title(entity, intent) do
    "#{Inflex.camelize(intent)} #{entity.name()}"
  end

  defp subtitle(_, _) do
    ""
  end

  defp action(entity, intent) do
    store = entity.plural
    "$store.#{store}.#{intent}()"
  end

  defp cancel(entity, :create) do
    "`/#/#{entity.plural()}`"
  end

  defp cancel(entity, _) do
    "`/#/#{entity.plural}/${$store.#{entity.plural}.item.id}`"
  end
end
