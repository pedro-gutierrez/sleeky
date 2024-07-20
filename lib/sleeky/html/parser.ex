defmodule Sleeky.Html.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  @impl true
  def parse({:html, _, [child]}, _opts), do: child
end
