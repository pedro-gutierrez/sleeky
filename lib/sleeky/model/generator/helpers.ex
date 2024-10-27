defmodule Sleeky.Model.Generator.Helpers do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(_model, _) do
    quote do
      import Sleeky.Model.Helpers
    end
  end
end
