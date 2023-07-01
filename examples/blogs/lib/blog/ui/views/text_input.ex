defmodule Blog.UI.Views.TextInput do
  use Bee.UI.View

  render do
    div class: "field" do
      label class: "label" do
        slot(:label)
      end

      div class: "control" do
        input class: "input",
              type: "text",
              placeholder: "{{ label }}",
              "data-name": "{{ name }}" do
        end
      end
    end
  end
end
