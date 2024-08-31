defmodule Blogs.Publishing.Comment do
  @moduledoc false
  use Sleeky.Model

  alias Blogs.Publishing.{Author, Post}

  model do
    attribute :body, kind: :string
    belongs_to Post
    belongs_to Author

    action :create do
      role :user do
        scope do
          one [:is_published, :author]
        end
      end
    end

    action :update do
      role :user do
        scope do
          one do
            :is_published

            all do
              :author
              :is_not_locked
            end
          end
        end
      end
    end

    action :list do
      role :user
    end

    action :delete do
      role :user, scope: :author
    end
  end
end
