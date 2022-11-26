defmodule Bee.Database.Table do
  @moduledoc false
  alias Bee.Database.Column

  defstruct [
    :name,
    columns: []
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def from_entity(entity) do
    name = entity.table()

    attribute_columns =
      entity.attributes()
      |> Enum.reject(&(&1.virtual || &1.timestamp))
      |> Enum.map(&Column.new/1)

    parent_columns = Enum.map(entity.parents(), &Column.new/1)

    %__MODULE__{name: name, columns: attribute_columns ++ parent_columns}
  end
end
