defmodule Sleeky.Entity.Generator.Helpers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_entity, _) do
    quote do
      import Sleeky.Entity.Helpers
    end
  end
end
