defmodule Blogs.Publishing.Post do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.Blog

  model do
    attribute :title, kind: :string
    attribute :published, kind: :timestamp
    belongs_to Blog
  end
end
