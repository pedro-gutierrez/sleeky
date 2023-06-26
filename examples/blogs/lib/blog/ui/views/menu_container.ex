defmodule Blog.UI.Views.MenuContainer do
  use Bee.UI.View

  render do
    div class: "navbar-menu", "data-mode": "nav" do
      div class: "navbar-start" do
        slot(:items)
      end

      div class: "navbar-end" do
        div class: "navbar-item", "data-public": true do
          view(Blog.UI.Views.Facebook)
        end
      end
    end
  end
end
