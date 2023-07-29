defmodule Sleeky.Views.Forms.Helpers do
  @moduledoc false

  alias Sleeky.Entity.Attribute
  alias Sleeky.Entity.Relation
  import Sleeky.Inspector

  def definition(messages, fields, buttons, opts) do
    contents = flatten([messages, fields, {:div, [class: "field is-grouped"], buttons}])

    attrs =
      [class: "box is-shadowless"]
      |> with_x_attr(:data, opts)
      |> with_x_attr(:init, opts)
      |> with_x_attr(:show, opts)

    {:div, attrs, contents}
  end

  defp with_x_attr(attrs, name, opts) do
    case Keyword.get(opts, name) do
      nil -> attrs
      value -> Keyword.put(attrs, String.to_atom("x-#{name}"), value)
    end
  end

  def messages(_ui, views) do
    {:view, module(views, Notifications)}
  end

  def button(title, click) do
    {:p, [class: "control"],
     [
       {:a, ["x-on:click": click, class: "button is-primary"],
        [
          title
        ]}
     ]}
  end

  def field(_ui, views, %Attribute{kind: :string} = attr) do
    {:view, module(views, Input),
     [
       {:label, attr.label},
       {:name, attr.name},
       {:kind, "text"}
     ]}
  end

  def field(_ui, views, %Attribute{kind: :text} = attr) do
    {:view, module(views, Textarea),
     [
       {:label, attr.label},
       {:name, attr.name}
     ]}
  end

  def field(_ui, views, %Attribute{kind: :enum} = attr) do
    {:view, module(views, Select),
     [
       {:label, attr.label},
       {:name, attr.name}
     ]}
  end

  def field(_ui, views, %Relation{} = rel) do
    {:view, module(views, EntitySelect),
     [
       {:label, rel.label},
       {:name, rel.name},
       {:entity, rel.target.plural}
     ]}
  end
end
