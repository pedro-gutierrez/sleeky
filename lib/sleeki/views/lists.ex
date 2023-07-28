defmodule Sleeki.Views.Lists do
  @moduledoc false

  alias Sleeki.UI.View

  import Sleeki.Inspector
  import Sleeki.Views.Components

  def ast(_ui, views, schema) do
    for entity <- schema.entities() do
      view = module_name(views, entity)
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
        defmodule unquote(view) do
          unquote(View.ast(definition, view))
        end
      end
    end
  end

  def module_name(views, entity) do
    form = entity.label() |> module(List)
    module(views, form)
  end
end
