defmodule Blogs.Publishing.Topic do
  @moduledoc false
  use Sleeky.Model

  model do
    attribute name: :id, kind: :integer, primary_key: true
    attribute :name, kind: :string

    key fields: [:name], unique: true
  end
end
