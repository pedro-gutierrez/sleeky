defmodule Sleeky.Model.Helpers do
  @moduledoc false

  def atom_keys(map) when is_map(map) do
    map
    |> Enum.map(fn
      {key, value} when is_atom(key) -> {key, value}
      {key, value} when is_binary(key) -> {String.to_existing_atom(key), value}
    end)
    |> Enum.into(%{})
  end
end
