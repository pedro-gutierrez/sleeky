defmodule Sleeky.Domain.Scopes do
  @moduledoc false

  @doc "Returns all the scopes defined for the given domain"
  def all(domain) do
    if domain.scopes do
      domain.scopes.scopes()
    else
      %{}
    end
  end
end
