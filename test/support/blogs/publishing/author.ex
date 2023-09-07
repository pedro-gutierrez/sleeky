defmodule Blogs.Publishing.Author do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.Blog

  model do
    has_many Blog
  end
end
