defmodule Bee.Migrations.Table do
  @moduledoc false
  alias Bee.Migrations.Column

  defstruct [
    :name,
    columns: []
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def from_entity(entity) do
    name = entity.table()
    columns = Column.all_for_entity(entity)

    %__MODULE__{name: name, columns: columns}
  end
end
