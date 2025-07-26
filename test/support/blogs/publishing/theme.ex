defmodule Blogs.Publishing.Theme do
  @moduledoc false
  use Sleeky.Model

  model do
    attribute :name, kind: :string, in: ["science", "finance"]

    unique fields: [:name] do
      on_conflict :merge, except: [:id]
    end

    action :create do
      role :guest
    end

    action :list do
      role :guest
    end
  end
end
