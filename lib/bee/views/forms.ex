defmodule Bee.Views.Forms do
  @moduledoc false

  import Bee.Inspector

  @forms [
    Bee.Views.Forms.Delete,
    Bee.Views.Forms.Create,
    Bee.Views.Forms.Update
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
