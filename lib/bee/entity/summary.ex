defmodule Bee.Entity.Summary do
  @moduledoc false
  alias Bee.Entity

  def new(%Entity{} = entity) do
    entity
    |> Map.put(:attributes, [])
    |> Map.put(:parents, [])
    |> Map.put(:children, [])
  end

  def new(other) do
    IO.inspect(other: other)

    raise "plop"
  end
end
