defmodule Bee.Views.Forms.Helpers do
  @moduledoc false

  alias Bee.Entity.Attribute
  alias Bee.Entity.Relation
  import Bee.Inspector

  def definition(show, data, messages, fields, buttons) do
    contents = flatten([messages, fields, {:div, [class: "field is-grouped"], buttons}])
    {:div, [class: "box is-shadowless", "x-data": data, "x-show": show], contents}
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
