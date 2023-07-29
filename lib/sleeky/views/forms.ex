defmodule Sleeky.Views.Forms do
  @moduledoc false

  import Sleeky.Inspector

  @forms [
    Sleeky.Views.Forms.Delete,
    Sleeky.Views.Forms.Create,
    Sleeky.Views.Forms.Update,
    Sleeky.Views.Forms.CreateChildren
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
