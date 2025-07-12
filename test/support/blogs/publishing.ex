defmodule Blogs.Publishing do
  @moduledoc false
  use Sleeky.Context

  context do
    scopes(Blogs.Scopes)

    model Blogs.Publishing.Author
    model Blogs.Publishing.Blog
    model Blogs.Publishing.Comment
    model Blogs.Publishing.Post
    model Blogs.Publishing.Theme
  end
end
