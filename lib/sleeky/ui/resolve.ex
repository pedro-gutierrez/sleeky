defmodule Sleeky.Ui.Resolve do
  @moduledoc """
  This is the frontend module in charge of resolving a tree of views
  """

  use Sleeky.Ui.Compound.Resolve
  use Sleeky.Ui.Each.Resolve
  use Sleeky.Ui.Markdown.Resolve
  use Sleeky.Ui.Html.Resolve
end
