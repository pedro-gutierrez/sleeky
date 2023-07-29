defmodule Sleeky.Entity.Summary do
  @moduledoc false
  alias Sleeky.Entity

  def new(%Entity{} = entity) do
    entity
    |> Map.put(:attributes, [])
    |> Map.put(:parents, [])
    |> Map.put(:children, [])
    |> Map.put(:keys, [])
    |> Map.put(:actions, [])
  end
end
