defmodule Blog.UI.Views.MenuContainer do
  use Bee.UI.View

  render do
    div class: "navbar-menu", "data-mode": "nav" do
      div class: "navbar-start", "data-private": true do
        slot(:items)
      end

      div class: "navbar-end" do
        div class: "navbar-item", "data-public": true do
          a href: "#/registrations/new", class: "button is-white" do
            "Register"
          end

          a href: "#/logins/new", class: "button is-white" do
            "Login"
          end
        end
      end
    end
  end
end
