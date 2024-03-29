defmodule Sleeky.Compare.NotNil do
  @moduledoc false

  def compare([v]) when is_list(v), do: Enum.all?(v, &(not is_nil(&1)))
  def compare([v]), do: not is_nil(v)
end
