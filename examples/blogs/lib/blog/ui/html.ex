defmodule Blog.UI.Html do
  use Bee.UI.View

  render do
    html class: "has-background-white-bis" do
      head do
        meta(charset: "UTF-8")
        script(src: "/assets/js/s.js")
        script(defer: true, src: "/assets/js/pumpkin.js")

        link(
          href: "/assets/css/bulma.min.css",
          rel: "stylesheet"
        )

        link(
          href: "/assets/css/fa.min.css",
          rel: "stylesheet"
        )

        link(
          href: "/assets/css/custom.css",
          rel: "stylesheet"
        )

        title do
          "Blogs"
        end
      end

      body do
        slot(:body)
      end
    end
  end
end
