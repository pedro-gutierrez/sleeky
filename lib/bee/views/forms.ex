defmodule Bee.Views.Forms do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View
  alias Bee.Entity.Attribute

  def ast(ui, views, schema) do
    form_view = module(ui, Form)

    for entity <- schema.entities() do
      [
        form(entity, :create, ui, views, form_view),
        form(entity, :update, ui, views, form_view)
      ]
    end
  end

  defp form(entity, intent, ui, views, form_view) do
    module_name = module_name(views, entity, intent)
    fields = form_fields(entity, intent, ui)
    title = title(entity, intent)
    subtitle = subtitle(entity, intent)
    action = action(entity, intent)
    definition = definition(form_view, title, subtitle, fields, action, intent)

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end

  defp module_name(views, entity, intent) do
    intent = Inflex.camelize(intent)
    form = entity.label() |> module("#{intent}Form")
    module(views, form)
  end

  defp form_fields(entity, _, ui) do
    entity.attributes
    |> Enum.reject(& &1.immutable)
    |> Enum.reject(& &1.virtual)
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.timestamp)
    |> Enum.reject(& &1.implied)
    |> Enum.map(&form_field(ui, &1))
  end

  def definition(name, title, subtitle, fields, action, intent) do
    {:div, ["x-show": "$store.router.mode == '#{intent}'"],
     [
       {:view, name,
        [
          {:title, [], title},
          {:subtitle, [], subtitle},
          {:fields, [], flatten(fields)},
          {:submit, [], action}
        ]}
     ]}
  end

  defp form_field(ui, %Attribute{kind: :string} = attr) do
    field_view = module(ui, FormInput)
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

  defp form_field(ui, %Attribute{kind: :text} = attr) do
    field_view = module(ui, FormText)
    model = model(attr)

    {:view, field_view,
     [
       {:label, attr.label},
       {:name, attr.name},
       {:model, model},
       {:placeholder, "Enter #{attr.name}"}
     ]}
  end

  defp form_field(ui, %Attribute{kind: :enum} = attr) do
    field_view = module(ui, FormDropdown)
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
end
