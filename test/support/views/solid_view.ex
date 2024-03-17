defmodule SolidView do
  @moduledoc false
  use Sleeky.Ui.View

  render do
    h1 class: "title {{ style }}" do
      "Some title"
    end
  end
end
