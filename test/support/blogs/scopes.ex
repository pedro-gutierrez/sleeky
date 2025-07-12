defmodule Blogs.Scopes do
  @moduledoc false
  use Sleeky.Scopes

  scopes roles: "current_user.roles" do
    scope :author do
      same do
        path "**.author"
        path "current_user"
      end
    end

    scope :is_public, debug: true do
      is_true do
        path "**.public"
      end
    end

    scope :self do
      same do
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
      is_false do
        path "**.locked"
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
