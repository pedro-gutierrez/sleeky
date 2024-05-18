defmodule Sleeky.Compare.Neq do
  @moduledoc false
  alias Sleeky.Compare.Eq

  def compare(values), do: not Eq.compare(values)
end
