defmodule Sleeki.Migrations.Step do
  @moduledoc false

  alias Sleeki.Database.State

  @type step :: struct()
  @type code :: tuple()

  @callback encode(step()) :: code()
  @callback decode(code()) :: step()
  @callback aggregate(step(), State.t()) :: State.t()
  @callback diff(State.t(), State.t()) :: [step()]
end
