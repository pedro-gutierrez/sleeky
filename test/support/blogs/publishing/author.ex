defmodule Blogs.Publishing.Author do
  @moduledoc false
  use Sleeky.Entity

  alias Blogs.Publishing.Blog

  entity do
    attribute :name, kind: :string
    attribute :profile, kind: :string, default: "publisher"
    has_many Blog

    action :create do
      role :guest
    end
  end
end
