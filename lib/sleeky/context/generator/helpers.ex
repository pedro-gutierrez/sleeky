defmodule Sleeky.Context.Generator.Helpers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _) do
    quote do
      import Sleeky.Context.Helpers
    end
  end
end
