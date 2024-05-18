defmodule Blogs.Publishing.Topic do
  @moduledoc false
  use Sleeky.Model

  model do
    attribute :name, kind: :string

    key fields: [:name], unique: true
  end
end
