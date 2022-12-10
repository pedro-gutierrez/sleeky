defmodule Bee.Context.Entities do
  @moduledoc false

  @stored_generators [
    Bee.Context.List,
    Bee.Context.Read,
    Bee.Context.Create,
    Bee.Context.Update,
    Bee.Context.Delete
  ]

  @virtual_generators []

  def ast(entities, repo, auth) do
    for e <- entities, g <- generators(e) do
      g.ast(e, repo, auth)
    end
  end

  defp generators(entity) do
    if entity.virtual? do
      @virtual_generators
    else
      @stored_generators
    end
  end
end
