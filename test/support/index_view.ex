defmodule IndexView do
  @moduledoc false
  use Sleeky.UI.View

  render do
    view LayoutView do
      header do
        view HeaderView
      end

      main do
        view MainView
      end
    end
  end
end
