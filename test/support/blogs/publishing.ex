defmodule Blogs.Publishing do
  @moduledoc false
  use Sleeky.Context

  context do
    authorization Blogs.Authorization

    model Blogs.Publishing.Author
    model Blogs.Publishing.Blog
    model Blogs.Publishing.Comment
    model Blogs.Publishing.Post
    model Blogs.Publishing.Topic
  end
end
