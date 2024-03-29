defmodule Blogs.Publishing.Comment do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.{Author, Post}

  model do
    attribute :body, kind: :string
    belongs_to Post
    belongs_to Author

    action :create do
      allow role: :user, scope: :is_published_or_author
    end

    action :edit do
      allow role: :user, scope: :is_published_or_author_and_is_not_locked
    end
  end
end
