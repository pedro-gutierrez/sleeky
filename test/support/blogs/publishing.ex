defmodule Blogs.Publishing do
  @moduledoc false
  use Sleeky.Context

  context do
    scopes do
      Blogs.Scopes
    end

    entities do
      Blogs.Publishing.Author
      Blogs.Publishing.Blog
      Blogs.Publishing.Comment
      Blogs.Publishing.Post
      Blogs.Publishing.Theme
    end
  end
end
