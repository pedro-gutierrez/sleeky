defmodule Bee.Views.Forms do
  @moduledoc false

  import Bee.Inspector
  alias Bee.UI.View
  alias Bee.Entity.Attribute

  def ast(ui, views, schema) do
    form_view = module(ui, Form)

    for entity <- schema.entities() do
      module_name = module_name(views, entity)
      definition = definition(ui, entity, form_view)

      quote do
        defmodule unquote(module_name) do
          unquote(View.ast(definition))
        end
      end
    end
  end

  defp module_name(views, entity) do
    form = entity.label() |> module(Form)
    module(views, form)
  end

  defp definition(ui, entity, form_view) do
    form_fields =
      entity.attributes
      |> Enum.reject(& &1.immutable)
      |> Enum.reject(& &1.virtual)
      |> Enum.reject(& &1.computed)
      |> Enum.reject(& &1.timestamp)
      |> Enum.reject(& &1.implied)
      |> Enum.map(&form_field(ui, &1))

    action = action(entity, :create)

    {:view, form_view,
     [
       {:title, [], "#{entity.label} form"},
       {:fields, [], flatten(form_fields)},
       {:submit, [], action}
     ]}
  end

  defp form_field(ui, %Attribute{kind: :string} = attr) do
    field_view = module(ui, FormInput)
    model = model(attr)

    {:view, field_view,
     [
       {:label, attr.label},
       {:name, attr.name},
       {:kind, :text},
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

  defp action(entity, name) do
    store = entity.plural
    "$store.#{store}.#{name}()"
  end
end
