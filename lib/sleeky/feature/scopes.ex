defmodule Sleeky.Feature.Scopes do
  @moduledoc false

  @doc "Returns all the scopes defined for the given feature"
  def all(feature) do
    if feature.scopes do
      feature.scopes.scopes()
    else
      %{}
    end
  end
end
