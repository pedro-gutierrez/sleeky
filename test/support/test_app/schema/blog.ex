defmodule TestApp.Schema.Blog do
  use Sleeky.Entity

  attribute :id, :string do
    primary_key()
  end

  belongs_to(:user)
end
