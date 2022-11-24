defmodule Bee.Migrations.Table do
  @moduledoc false

  defstruct [
    :name,
    columns: [],
    indices: [],
    constraints: []
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def from_entity(entity) do
    %__MODULE__{name: entity.table()}
  end
end
