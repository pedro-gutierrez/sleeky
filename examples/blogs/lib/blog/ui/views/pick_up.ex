defmodule Blog.UI.Views.PickUp do
  use Bee.UI.View

  render do
    div "data-pickup": "{{ scope }}", "data-pickup-name": "{{ name }}" do
      "TODO"
    end
  end

  # {:div, [data("pickup", scope), data("pickup-name", name)],
  #   [
  #     {:p, [], [label_view(name)]},
  #     {:p, [],
  #      [
  #        {:span, [data("pickup-selection", "display")], []}
  #      ]},
  #     {:p, [],
  #      [
  #        {:input, [data("pickup-input"), type: "text"], []}
  #      ]},
  #     {:div, [],
  #      [
  #        {:template, [data(:each)],
  #         [
  #           {:p, [],
  #            [
  #              field_view(:display)
  #            ]}
  #         ]}
  #      ]}
  #   ]}
end
