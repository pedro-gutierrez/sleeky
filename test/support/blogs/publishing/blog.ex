defmodule Blogs.Publishing.Blog do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.{Author, Post, Theme}

  model do
    attribute :name, kind: :string
    attribute :published, kind: :boolean, required: true, default: false
    attribute :public, kind: :boolean, required: false, default: false
    belongs_to Author
    belongs_to Theme, required: false
    has_many Post
    key fields: [:author, :name], unique: true

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
