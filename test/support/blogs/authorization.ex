defmodule Blogs.Authorization do
  @moduledoc false
  use Sleeky.Authorization

  authorization roles: "current_user.roles" do
    scope :author do
      eq do
        path "**.author"
        path "current_user"
      end
    end

    scope :is_public do
      eq do
        path "**.public"
        true
      end
    end

    scope :self do
      eq do
        path "user.id"
        path "current_user.id"
      end
    end

    scope :is_published do
      not_nil do
        path "**.published_at"
      end
    end

    scope :is_not_locked do
      eq do
        path "**.locked"
        false
      end
    end

    scope :is_published_or_author do
      one [:author, :is_published]
    end

    scope :is_published_and_is_not_locked do
      all [:is_published, :is_not_locked]
    end

    scope :is_published_or_author_and_is_not_locked do
      all [:is_published_or_author, :is_not_locked]
    end
  end
end
