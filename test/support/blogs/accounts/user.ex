defmodule Blogs.Accounts.User do
  use Sleeky.Model

  alias Blog.Blogs.Publishing.Blog

  model do
    attribute :email, kind: :string
    has_many Blog
  end
end
