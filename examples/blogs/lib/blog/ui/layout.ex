defmodule Blog.UI.Layout do
  use Bee.UI.View

  render do
    header do
    end
    nav class: "navbar" do
      div class: "navbar-brand" do
        a href: "/", class: "navbar-item ml-3" do
          span [] do
            "Home"
          end
        end
      end
      slot(:menu)
    end
    section class: "hero has-background-success-light" do
      div class: "hero-body" do
        div class: "container" do
          slot(:notifications)
          slot(:breadcrumbs)
          slot(:main)
        end
      end
    end
    footer class: "footer" do
      div class: "content has-text-centered" do
        p do
          "Made with"
          i(class: "ml-1 mr-1 fa-solid fa-heart has-text-danger")
          "in Elixir"
        end
      end
    end
  end
end
