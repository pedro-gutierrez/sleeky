defmodule Blogs.Publishing.Blog do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.Author
  alias Blogs.Publishing.Post

  model do
    attribute :id, kind: :string, primary_key: true
    attribute :name, kind: :string
    belongs_to Author
    has_many Post
    key fields: [:author, :name], unique: true
  end
end
