defmodule Sleeky.Context.Scopes do
  @moduledoc false

  @doc "Returns all the scopes defined for the given context"
  def all(context) do
    if context.scopes do
      context.scopes.scopes()
    else
      %{}
    end
  end
end
