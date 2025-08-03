defmodule Blogs.Publishing do
  @moduledoc false
  use Sleeky.Feature

  feature do
    scopes do
      Blogs.Scopes
    end

    models do
      Blogs.Publishing.Author
      Blogs.Publishing.Blog
      Blogs.Publishing.Comment
      Blogs.Publishing.Post
      Blogs.Publishing.Theme
    end
  end
end
