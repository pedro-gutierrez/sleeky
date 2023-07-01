defmodule Blog.UI.Views.Title do
  use Bee.UI.View

  render do
    h1 class: "title" do
      slot(:title)
    end
  end
end
