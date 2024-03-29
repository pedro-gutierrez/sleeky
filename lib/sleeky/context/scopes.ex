defmodule Sleeky.Context.Scopes do
  @moduledoc false

  @doc "Returns all the scopes defined for the given context module"
  def all(context) do
    if context.authorization do
      context.authorization.scopes()
    else
      %{}
    end
  end
end
