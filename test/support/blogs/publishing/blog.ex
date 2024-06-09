defmodule Blogs.Publishing.Blog do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.Author
  alias Blogs.Publishing.Post

  model do
    attribute :name, kind: :string
    attribute :published, kind: :boolean, required: true, default: false
    belongs_to Author
    has_many Post
    key fields: [:author, :name], unique: true

    action :read do
      allow role: :user
    end

    action :create do
      allow role: :user, scope: :author
    end

    action :list do
      allow role: :user, scope: :author
    end

    action :update do
      allow role: :user, scope: :author
    end

    action :delete do
      allow role: :user, scope: :author
    end
  end
end
