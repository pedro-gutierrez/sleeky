defmodule Blogs.Ui.Views.Blog do
  @moduledoc false
  use Sleeky.Ui.View

  view do
    html do
      head do
        title "My Blog"
      end

      body do
        h1 "Welcome to my Blog"
      end
    end
  end
end
