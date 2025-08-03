defmodule Blogs.Publishing.Blog do
  @moduledoc false
  use Sleeky.Entity

  alias Blogs.Publishing.{Author, Post, Theme}

  entity do
    attribute :name, kind: :string
    attribute :published, kind: :boolean, required: true, default: false
    attribute :public, kind: :boolean, required: false, default: false
    belongs_to Author
    belongs_to Theme, required: false
    has_many Post
    unique fields: [:author, :name]

    action :read do
      role :user
    end

    action :create do
      role :user, scope: :author
    end

    action :list do
      role :user, scope: :author
    end

    action :update do
      role :user, scope: :author
    end

    action :delete do
      role :user, scope: :author
    end
  end
end
