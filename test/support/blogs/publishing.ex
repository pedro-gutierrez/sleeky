defmodule Blogs.Publishing do
  @moduledoc false
  use Sleeky.Context

  context do
    model Blogs.Publishing.Author
    model Blogs.Publishing.Blog
    model Blogs.Publishing.Comment
    model Blogs.Publishing.Post
    model Blogs.Publishing.Topic
  end
end
