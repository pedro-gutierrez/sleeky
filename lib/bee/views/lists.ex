defmodule Bee.Views.Lists do
  @moduledoc false

  alias Bee.UI.View

  import Bee.Inspector
  import Bee.Views.Components

  def ast(_ui, views, schema) do
    for entity <- schema.entities() do
      module_name = module_name(views, entity)
      plural = entity.plural()

      definition =
        {:div, [data(:scope, plural), data(:mode, :list)],
         [
           {:h1, [], [entity.plural_label()]},
           {:p, [], [link_view("/#{plural}/new", "Create #{entity.name()}")]},
           {:div, [data(:filter)], [label_view("Filter"), input_view(:text, :query)]},
           {:ul, [],
            [
              {:template, [data(:each, plural)],
               [
                 {:li, [],
                  [
                    {:a, [data(:link, "/#{plural}/$id")],
                     [
                       field_view(:display)
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
  end

  def module_name(views, entity) do
    form = entity.label() |> module(List)
    module(views, form)
  end
end
