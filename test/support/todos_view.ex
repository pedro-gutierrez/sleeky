defmodule TodosView do
  use Sleeky.Ui.View

  render do
    view ListView do
      items do
        [[title: "Buy Food"], [title: "Write Elixir"]]
      end
    end
  end
end
