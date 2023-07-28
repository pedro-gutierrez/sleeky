defmodule Sleeki.Views.Forms do
  @moduledoc false

  import Sleeki.Inspector

  @forms [
    Sleeki.Views.Forms.Delete,
    Sleeki.Views.Forms.Create,
    Sleeki.Views.Forms.Update,
    Sleeki.Views.Forms.CreateChildren
  ]

  def ast(ui, views, schema) do
    for form <- @forms, entity <- schema.entities do
      if form.action(entity) do
        form.ast(ui, views, entity)
      else
        nil
      end
    end
    |> flatten()
  end

  def module_name(views, entity, intent) do
    intent = Inflex.camelize(intent)
    form = entity.label() |> module("#{intent}Form")
    module(views, form)
  end
end
