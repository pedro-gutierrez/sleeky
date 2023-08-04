defmodule HeaderView do
  @moduledoc false
  use Sleeky.Ui.View

  render do
    nav do
      a href: "/" do
        "Home"
      end
    end
  end
end
