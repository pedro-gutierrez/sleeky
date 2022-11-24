defmodule Bee.Migrations.Table do
  @moduledoc false

  defstruct [
    :name,
    columns: [],
    indices: [],
    constraints: []
  ]

  def from_entity(entity) do
    %__MODULE__{name: entity.table()}
  end
end
