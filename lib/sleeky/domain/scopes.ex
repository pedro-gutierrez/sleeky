defmodule Sleeky.Domain.Scopes do
  @moduledoc false

  @doc "Returns all the scopes defined for the given context module"
  def all(context) do
    if context.scopes do
      context.scopes.scopes()
    else
      %{}
    end
  end
end
