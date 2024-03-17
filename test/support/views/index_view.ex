defmodule IndexView do
  @moduledoc false
  use Sleeky.Ui.View

  render do
    view LayoutView do
      slot :header do
        view HeaderView
      end

      slot :main do
        view MainView
      end
    end
  end
end
