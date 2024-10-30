defmodule Blogs.Publishing.Post do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.{Author, Blog, Comment}

  model do
    attribute :title, kind: :string
    attribute :published_at, kind: :datetime, required: false
    attribute :locked, kind: :boolean, required: true, default: false
    attribute :published, kind: :boolean, required: true, default: false
    attribute :deleted, kind: :boolean, required: true, default: false
    belongs_to Blog
    belongs_to Author
    has_many Comment

    action :update do
      role :user, scope: :author
    end

    action :list do
      role :user do
        scope do
          all [:is_published, :is_not_locked]
        end
      end
    end

    action :delete do
      role :user, scope: :author
    end

    action :read do
      role :user, scope: :author
    end

    action :create do
      role :user, scope: :author
    end
  end
end
