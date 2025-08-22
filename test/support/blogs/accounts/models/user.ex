defmodule Blogs.Accounts.User do
  use Sleeky.Model

  model do
    attribute :email, kind: :string
    attribute :public, kind: :boolean, default: false
    attribute :external_id, kind: :id

    unique fields: [:email]

    has_many Blogs.Accounts.Credential
  end
end
