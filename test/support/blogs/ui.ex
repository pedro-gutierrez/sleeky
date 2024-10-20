defmodule Blogs.Ui do
  @moduledoc false
  use Sleeky.Ui

  ui do
    page Blogs.Ui.Index

    context Blogs.Accounts
  end
end
