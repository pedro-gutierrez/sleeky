defmodule Bee.Entity.ForeignKey do
  defstruct [:name, :field]

  def new(rel) do
    %__MODULE__{
      field: String.to_atom("#{rel.entity.name}_#{rel.name}"),
      name: String.to_atom("#{rel.entity.table}_#{rel.name}_id_fkey")
    }
  end
end
