defmodule Bee.Views.Forms do
  @moduledoc false

  import Bee.Inspector
  alias Bee.Entity.Action
  alias Bee.UI.View
  alias Bee.Entity.Attribute
  alias Bee.Entity.Relation

  def ast(ui, views, schema) do
    form_view = form_view(ui, views)

    schema.entities()
    |> Enum.flat_map(fn e ->
      for action <- e.actions, do: Map.put(action, :entity, e)
    end)
    |> Enum.map(&form(ui, views, form_view, &1))
    |> flatten()
  end

  defp form_view(_ui, views) do
    module(views, Form)
  end

  defp form(_ui, views, _form_view, %Action{name: name, entity: entity}) when name == :delete do
    module_name = module_name(views, entity, name)
    submit = action(entity, name)
    cancel = cancel(entity, name)

    definition =
      {:div,
       [
         class: "box hero is-shadowless has-background-danger-light",
         "x-show": "$store.default.should_display('#{entity.plural}', 'delete')"
       ],
       [
         {:div, [class: "container"],
          [
            {:p, [class: "block has-text-danger"],
             ["Are you sure you want to delete this item?"]},
            {:div, [class: "field is-grouped is-grouped-centered"],
             [
               {:div, [class: "control"],
                [
                  {:a, [href: "#", class: "button is-danger", "x-on:click": submit],
                   [
                     "Delete"
                   ]}
                ]},
               {:div, [class: "control"],
                [
                  {:a, [class: "button is-light", "x-bind:href": cancel],
                   [
                     "Cancel"
                   ]}
                ]}
             ]}
          ]}
       ]}

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end

  defp form(ui, views, form_view, %Action{name: name, entity: entity})
       when name in [:create, :update] do
    module_name = module_name(views, entity, name)
    fields = form_fields(entity, name, ui, views)
    title = title(entity, name)
    subtitle = subtitle(entity, name)
    action = action(entity, name)
    cancel = cancel(entity, name)
    definition = definition(entity, form_view, title, subtitle, fields, action, cancel, name)

    quote do
      defmodule unquote(module_name) do
        unquote(View.ast(definition))
      end
    end
  end

  defp form(_ui, _views, _form_view, _action), do: nil

  def module_name(views, entity, intent) do
    intent = Inflex.camelize(intent)
    form = entity.label() |> module("#{intent}Form")
    module(views, form)
  end

  defp form_fields(_entity, :delete, _ui, _views) do
    []
  end

  defp form_fields(entity, _, ui, views) do
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
    |> Enum.map(&form_field(ui, views, &1))
  end

  defp parent_fields(entity, ui, views) do
    entity.parents
    |> Enum.reject(& &1.computed)
    |> Enum.reject(& &1.computed)
    |> Enum.map(&form_field(ui, views, &1))
  end

  def definition(entity, name, title, subtitle, fields, submit, cancel, intent) do
    {:div, ["x-show": "$store.default.should_display('#{entity.plural}', '#{intent}')"],
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

  defp entity_select_view(_ui, views) do
    module(views, EntitySelect)
  end

  defp form_field(ui, views, %Attribute{kind: :string} = attr) do
    field_view = input_view(ui, views)

    {:view, field_view,
     [
       {:label, attr.label},
       {:name, attr.name},
       {:kind, "text"},
       {:model, "$store.default.item.#{attr.name}"},
       {:placeholder, "Enter #{attr.name}"}
     ]}
  end

  defp form_field(ui, views, %Attribute{kind: :text} = attr) do
    field_view = textarea_view(ui, views)

    {:view, field_view,
     [
       {:label, attr.label},
       {:name, attr.name},
       {:model, "$store.default.item.#{attr.name}"},
       {:placeholder, "Enter #{attr.name}"}
     ]}
  end

  defp form_field(ui, views, %Attribute{kind: :enum} = attr) do
    field_view = select_view(ui, views)

    {:view, field_view,
     [
       {:label, attr.label},
       {:name, attr.name},
       {:model, "$store.default.item.#{attr.name}"},
       {:placeholder, "Enter #{attr.name}"}
     ]}
  end

  defp form_field(ui, views, %Relation{} = rel) do
    field_view = entity_select_view(ui, views)

    {:view, field_view,
     [
       {:label, rel.label},
       {:name, rel.name},
       {:store, "default"},
       {:entity, rel.target.plural},
       {:relation, rel.name}
     ]}
  end

  defp title(entity, intent) do
    "#{Inflex.camelize(intent)} #{entity.name()}"
  end

  defp subtitle(_, _) do
    ""
  end

  defp action(_entity, intent) do
    "$store.default.#{intent}()"
  end

  defp cancel(entity, :create) do
    "`/#/#{entity.plural()}`"
  end

  defp cancel(entity, _) do
    "`/#/#{entity.plural}/${$store.default.item.id}`"
  end
end
