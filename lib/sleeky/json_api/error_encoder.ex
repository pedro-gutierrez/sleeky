defmodule Sleeky.JsonApi.ErrorEncoder do
  @moduledoc """
  A generic json api error encoder
  """

  def encode_errors(reason) when is_atom(reason), do: encode_errors(%{reason: reason})

  def encode_errors(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> encode_errors()
  end

  def encode_errors(errors), do: {:error, errors}
end
