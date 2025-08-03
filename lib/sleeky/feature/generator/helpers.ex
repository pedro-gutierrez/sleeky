defmodule Sleeky.Feature.Generator.Helpers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _) do
    quote do
      import Sleeky.Feature.Helpers
    end
  end
end
