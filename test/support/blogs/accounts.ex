defmodule Blogs.Accounts do
  @moduledoc false
  use Sleeky.Domain

  domain do
    models do
      Blogs.Accounts.User
    end

    scopes do
      Blogs.Scopes
    end
  end
end
