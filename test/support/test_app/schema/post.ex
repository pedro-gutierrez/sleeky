defmodule TestApp.Schema.Post do
  use Sleeky.Entity

  attribute :title, :string do
  end

  belongs_to(:blog)
end
