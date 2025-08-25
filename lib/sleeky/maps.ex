defmodule Sleeky.Maps do
  @moduledoc false

  @doc """
  Converts a struct, map or keyword list into a plain map
  """
  def plain_map(data) when is_struct(data), do: Map.from_struct(data)
  def plain_map(data) when is_map(data), do: data
  def plain_map(data) when is_list(data), do: Map.new(data)

  def string_keys(%Date{} = date), do: date
  def string_keys(%DateTime{} = datetime), do: datetime

  def string_keys(list) when is_list(list) do
    Enum.map(list, &string_keys/1)
  end

  def string_keys(map) when is_map(map) do
    map
    |> plain_map()
    |> Enum.map(fn {key, value} -> {to_string(key), string_keys(value)} end)
    |> Enum.into(%{})
  end

  def string_keys(value) do
    value
  end
end
