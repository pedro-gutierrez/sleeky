defmodule Blogs.Publishing.Author do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.Blog

  model do
    attribute :name, kind: :string
    has_many Blog
  end
end
