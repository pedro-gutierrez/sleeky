defmodule Blogs.Accounts.User do
  use Sleeky.Model

  model do
    attribute :email, kind: :string
    attribute :public, kind: :boolean, default: false

    action :edit do
      allow role: :user, scope: :self
    end

    action :list do
      allow role: :user, scope: :is_public
    end
  end
end
