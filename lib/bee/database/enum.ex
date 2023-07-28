defmodule Sleeki.Database.Enum do
  @moduledoc false

  defstruct [:name, :values]

  def new(name, values \\ nil) do
    struct(__MODULE__, name: name, values: values)
  end
end
