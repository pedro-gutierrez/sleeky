defmodule Blogs.Accounts do
  @moduledoc false
  use Sleeky.Domain

  domain do
    model Blogs.Accounts.User

    scopes do
      Blogs.Scopes
    end
  end
end
