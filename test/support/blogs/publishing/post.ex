defmodule Blogs.Publishing.Post do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.Blog

  model do
    attribute :title, kind: :string
    attribute :published_at, kind: :timestamp, required: false
    attribute :locked, kind: :boolean, required: true, default: false
    attribute :published, kind: :boolean, required: true, default: false
    attribute :deleted, kind: :boolean, required: true, default: false
    belongs_to Blog

    action :edit do
      allow role: :user, scope: :author
    end

    action :list do
      allow role: :user, scope: :is_published_and_is_not_locked
    end
  end
end
