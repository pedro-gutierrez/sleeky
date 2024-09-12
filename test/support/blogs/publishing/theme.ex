defmodule Blogs.Publishing.Theme do
  @moduledoc false
  use Sleeky.Model

  model do
    attribute :name, kind: :string, in: ["science", "finance"]
    unique [:name]
  end
end
