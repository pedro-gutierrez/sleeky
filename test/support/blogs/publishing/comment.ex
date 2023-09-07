defmodule Blogs.Publishing.Comment do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.{Author, Post}

  model do
    attribute :body, kind: :string
    belongs_to Post
    belongs_to Author
  end
end
