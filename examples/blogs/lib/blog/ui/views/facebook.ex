defmodule Blog.UI.Views.Facebook do
  use Bee.UI.View

  render do
    a href: "/facebook/oauth", class: "button is-light is-plop" do
      span class: "icon is-small" do
        i(class: "fa-brands fa-facebook")
      end

      span do
        "Start with Facebook"
      end
    end
  end
end
