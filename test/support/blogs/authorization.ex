defmodule Blogs.Authorization do
  @moduledoc false
  use Sleeky.Authorization

  authorization do
    roles(path: "current_user.roles")

    scope :owner do
      equal do
        "**.user"
        "current_user"
      end
    end
  end
end
