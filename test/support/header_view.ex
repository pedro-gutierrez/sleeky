  defmodule HeaderView do
    @moduledoc false
    use Sleeky.UI.View

    render do
      nav do
        a href: "/" do
          "Home"
        end
      end
    end
  end
