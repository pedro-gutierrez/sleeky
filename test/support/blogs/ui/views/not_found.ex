defmodule Blogs.Ui.Views.NotFound do
  @moduledoc false
  use Sleeky.Ui.View

  view do
    html do
      head do
        title "Not found"
      end

      body do
        h1 "No such route"
      end
    end
  end
end
