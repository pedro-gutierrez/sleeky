defmodule Bee.Entity.Summary do
  @moduledoc false
  alias Bee.Entity

  def new(%Entity{} = entity) do
    entity
    |> Map.put(:attributes, [])
    |> Map.put(:parents, [])
    |> Map.put(:children, [])
    |> Map.put(:keys, [])
  end
end
