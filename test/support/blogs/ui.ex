defmodule Blogs.Ui do
  @moduledoc false
  use Sleeky.Ui

  ui do
    namespaces do
      Blogs.Ui.Namespaces.Root
    end
  end
end
