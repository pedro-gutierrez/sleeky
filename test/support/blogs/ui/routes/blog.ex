defmodule Blogs.Ui.Routes.Blog do
  @moduledoc false
  use Sleeky.Ui.Route

  route "/blogs" do
    action Blogs.Ui.Actions.Blog

    view Blogs.Ui.Views.Blog

    view "not_found" do
      Blogs.Ui.Actions.BlogNotFound
    end
  end
end
