defmodule Sleeky.Domain.Generator.Helpers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_, _) do
    quote do
      import Sleeky.Domain.Helpers
    end
  end
end
