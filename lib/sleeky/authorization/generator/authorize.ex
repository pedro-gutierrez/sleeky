defmodule Sleeky.Authorization.Generator.Authorize do
  @moduledoc false
  @behaviour Diesel.Generator

  @impl true
  def generate(target, definition) do
    IO.inspect(target: target, definition: definition)

    quote do
    end
  end
end
