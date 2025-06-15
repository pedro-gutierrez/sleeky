defmodule Blogs.Ui.Namespaces.Root do
  @moduledoc false
  use Sleeky.Ui.Namespace

  namespace "/" do
    routes do
      Blogs.Ui.Routes.Index
      Blogs.Ui.Routes.Blog
    end
  end
end
