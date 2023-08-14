defmodule TestApp.Schema.Topic do
  use Sleeky.Entity

  attribute :id, :integer do
    primary_key()
  end

  attribute :name, :string
end
