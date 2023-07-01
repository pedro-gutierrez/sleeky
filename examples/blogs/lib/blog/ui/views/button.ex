defmodule Blog.UI.Views.Button do
  use Bee.UI.View

  render do
    button class: "button is-primary", "data-action": "{{ action }}" do
      slot(:label)
    end
  end
end
