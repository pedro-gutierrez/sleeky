defmodule Blogs.Accounts.User do
  use Sleeky.Model

  model do
    attribute :email, kind: :string
    attribute :public, kind: :boolean, default: false
    key fields: [:email], unique: true

    action :read do
      role :user, scope: :self
    end

    action :update do
      role :user, scope: :self
    end

    action :list do
      role :user, scope: :is_public
    end
  end
end
