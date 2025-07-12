defmodule Blogs.Publishing do
  @moduledoc false
  use Sleeky.Domain

  domain do
    scopes do
      Blogs.Scopes
    end

    model Blogs.Publishing.Author
    model Blogs.Publishing.Blog
    model Blogs.Publishing.Comment
    model Blogs.Publishing.Post
    model Blogs.Publishing.Theme
  end
end
