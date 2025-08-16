defmodule Sleeky.Error do
  @moduledoc """
  Error utilities
  """

  def format(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> format()
  end

  def format(error) when is_atom(error), do: to_string(error)
  def format(error) when is_binary(error), do: error
  def format(error), do: inspect(error)
end
