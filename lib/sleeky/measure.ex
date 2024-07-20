defmodule Sleeky.Measure do
  @moduledoc false

  def micros(function) do
    function
    |> :timer.tc()
    |> elem(0)
  end
end
