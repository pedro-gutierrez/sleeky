defmodule Bee.Entity.ForeignKey do
  @moduledoc false
  
  import Bee.Inspector
  
  defstruct [:name, :field]

  def new(rel) do
    %__MODULE__{
      field: join([rel.entity.name, rel.name]),
      name: join([rel.entity.table, rel.name, :id, :fkey])
    }
  end
end
