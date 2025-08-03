defmodule Sleeky.Entity.Helpers do
  @moduledoc false

  import Ecto.Changeset

  def atom_keys(map) when is_map(map) do
    map
    |> Enum.map(fn
      {key, value} when is_atom(key) -> {key, value}
      {key, value} when is_binary(key) -> {String.to_existing_atom(key), value}
    end)
    |> Enum.into(%{})
  end

  def validate_uuid(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      case Ecto.UUID.cast(value) do
        {:ok, _} -> []
        :error -> [{field, "is not a valid UUID"}]
      end
    end)
  end
end
