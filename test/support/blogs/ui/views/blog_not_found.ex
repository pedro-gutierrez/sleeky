defmodule Blogs.Ui.Views.BlogNotFound do
  @moduledoc false
  use Sleeky.Ui.View

  view do
    html do
      head do
        title "Not found"
      end

      body do
        h1 "No such blog"
      end
    end
  end
end
