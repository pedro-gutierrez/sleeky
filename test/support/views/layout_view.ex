defmodule LayoutView do
  @moduledoc false
  use Sleeky.Ui.View

  render do
    html do
      head do
        meta(charset: "utf-8")
        title("Some title")
        link(rel: "stylesheet", href: "/some.css")
      end

      body do
        header do
          slot :header
        end

        main do
          slot :main
        end

        footer do
          "This is the footer"
        end
      end
    end
  end
end
